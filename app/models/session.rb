﻿# encoding: utf-8

require 'prawn'
require 'prawn/measurement_extensions'

class Session < ActiveRecord::Base
  include PdfHelper

  # Session States
  DRAFT = 0
  CANCELED = 1
  CONFIRMED = 2
  AVAILABLE_TOPICS_AND_NAMES = {
    "pleasure" => "Plaisir & Excellence",
    "sharing" => "Partage & Émulation",
    "desire" => "Désir & Réalité",
    "change" => "Changement & Energie",
  }
  AVAILABLE_TOPICS_AND_NAMES_FOR_SELECT = AVAILABLE_TOPICS_AND_NAMES.invert
  AVAILABLE_TOPICS = AVAILABLE_TOPICS_AND_NAMES.keys
  AVAILABLE_TOPIC_NAMES = AVAILABLE_TOPICS_AND_NAMES.values
  AVAILABLE_LAPTOPS_REQUIRED = { "non" => "non", "oui" => "oui"}
  AVAILABLE_DURATION = [ "25 min", "50 min", "110 min", "140 min" ]
  AVAILABLE_SESSION_TYPE = [ "Session en français", "Session in english" ]
  AVAILABLE_STATES = {"Draft" => 0, "Canceled" => 1, "Confirmed" => 2 }

  FIELDS_THAT_NEED_TO_BE_COMPLETE=[:short_description, :session_type, :duration, :session_goal, :outline_or_timetable]

  belongs_to :first_presenter, :class_name => 'Presenter'
  belongs_to :second_presenter, :class_name => 'Presenter'

  has_many :reviews, :dependent => :destroy
  has_many :votes
  attr_accessible :description, :title, :first_presenter_email, :second_presenter_email 
  attr_accessible :sub_title, :short_description, :session_type, :topic
  attr_accessible :duration, :intended_audience, :experience_level
  attr_accessible :max_participants, :laptops_required, :other_limitations, :room_setup, :materials_needed
  attr_accessible :session_goal, :outline_or_timetable
  attr_accessible :material_description, :material_url
  attr_accessible :state

  validates :title, :presence => true
  validates :description, :presence => true
  validates :first_presenter, :presence => true
  validates :first_presenter_email, :format => { :with => Presenter::EMAIL_REGEXP }
  validates :second_presenter_email, :format => { :with => Presenter::EMAIL_REGEXP }
  validates :topic, :inclusion => { :in => AVAILABLE_TOPICS_AND_NAMES_FOR_SELECT.values, :message => "a une valeur incorrecte: %{value}. Entrez une nature de session valable." }, :allow_blank => true
  validates :laptops_required, :inclusion => { :in => AVAILABLE_LAPTOPS_REQUIRED.values, :message => "a une valeur incorrecte: %{value}. Saisissez oui ou non." }, :allow_blank => true 
  validates :duration, :inclusion => { :in => AVAILABLE_DURATION, :message => "a une valeur incorrecte: %{value}. " }, :allow_blank => true 
  validates_numericality_of :max_participants, :allow_blank => true
  validates :session_type, :inclusion => { :in => AVAILABLE_SESSION_TYPE, :message => "a une valeur incorrecte: %{value}. " }, :allow_blank => true


  public

  def canceled?
    state == CANCELED
  end

  def confirmed?
    state == CONFIRMED
  end
  
  def first_presenter_email
    first_presenter && first_presenter.email || ''
  end

  def second_presenter_email
    second_presenter && second_presenter.email || ''
  end
  def first_presenter_email=(value)
    return unless value and not value.empty? #not allowed to remove first presenter
    self.first_presenter = Presenter.includes(:account).where('lower(accounts.email) = ?', value.downcase).first  || Presenter.create_from_archived_presenter(value)
  end

  def second_presenter_email=(value)
    if value.nil? or value.empty?
      self.second_presenter = nil 
    else
      self.second_presenter = Presenter.includes(:account).where('lower(accounts.email) = ?', value.downcase).first  || Presenter.create_from_archived_presenter(value)
    end
  end

  def presenter_names
    presenters.collect {|presenter| presenter.name }.join(' & ')
  end

  def presenters 
    [ first_presenter, second_presenter ].compact
  end

  def presenter_has_voted_for?(presenter_id) 
    votes.exists?( :presenter_id => presenter_id ) 
  end

  def self.topic_name(topic)
    AVAILABLE_TOPICS_AND_NAMES[topic] || ""
  end

  def topic_name
    Session.topic_name(topic) 
  end

  def printable_max_participants
    (!max_participants.nil? and !max_participants.empty?  and max_participants.to_i>0) ?  "Max: " + max_participants.to_i.to_s : ""
  end

  def printable_laptops_required
    (laptops_required and laptops_required == "oui") ?  "Apporter ordi" : ""
  end

  def status (since)
    [update_status(since),  review_status(since), comment_status(since)].reject(&:empty?).join(" ")
  end

  def update_status (since)
    if created_at > since
      "NOUVEAU" 
    elsif !updated_at.nil? && updated_at >  since
      "MIS A JOUR"
    else
      ""
    end
  end

  def review_status (since)
    if reviews.any?{|r| r.created_at > since}
      "REVU"
    else
      ""
    end
  end

  def comment_status (since)
    if reviews.any?{|r| r.comments.any? {|c| c.created_at > since.to_date } }
      "COMMENTÉ"
    else
      ""
    end
  end

  def has_new_review?
    reviews.any? do |r| 
      r.created_at > updated_at && !r.comments.any? {|c| presenters.include?(c.presenter)}
    end
  end

  def complete?
    ! Session::FIELDS_THAT_NEED_TO_BE_COMPLETE.any?{|field| attributes[field.to_s].blank?}
  end

  def limited?
    max_participants.present?
  end

  def laptops_required?
    laptops_required.present? && laptops_required == "oui"
  end

  def has_materials?
    material_description.present? && material_description.length > 0 &&
      material_url.present? && material_url.length > 0
  end

  def self.fields_that_need_to_be_complete_printable
    FIELDS_THAT_NEED_TO_BE_COMPLETE.collect{|f| f.to_s.gsub(/_/," ")}.join(", ")
  end

  def self.generate_program_committee_cards_pdf(file_name)
    Prawn::Document.generate file_name, 
      :page_size => 'A6', :page_layout => :landscape,
      :top_margin => 3.5.mm, :bottom_margin => 3.5.mm,
      :left_margin => 7.mm, :right_margin => 7.mm do |pdf|
      Session.all.each_with_index do |session, i| 
        pdf.start_new_page if i>0
        session.program_committee_card_content(pdf)
      end
    end
  end

  def program_committee_card_content(pdf)
    pdf.font_size 10
    pdf.text id.to_s, :align => :right, :size => 6
    pdf.move_up 4.mm
    pdf.text "#{votes.size} votes"
    pdf.text "#{reviews.size} revues"
    pdf.bounding_box([0, 85.mm], :width => 135.mm) do 
      pdf.text title, :align => :center, :size => 18
      pdf.text sub_title, :align => :center, :style => :italic, :size => 8 if !sub_title.nil? 
    end
    pdf.bounding_box([0, 65.mm], :width => 135.mm) do 
      wikinize_for_pdf(short_description, pdf) if !short_description.nil? 
    end
    pdf.bounding_box([0, 10.mm], :width => 135.mm, :height => 12.mm ) do 
      pdf.text "Orateurs:"
      pdf.text "Format: "
      pdf.text "Nature: "
    end
    pdf.bounding_box([20.mm, 10.mm], :width => 113.mm, :height => 12.mm ) do 
      pdf.text presenter_names
      pdf.text session_type.truncate(60)if !session_type.nil? 
      pdf.text topic_name
    end
    pdf.bounding_box([100.mm, 10.mm], :width => 35.mm, :height => 12.mm ) do 
      pdf.text printable_max_participants, :align => :right
      pdf.text printable_laptops_required, :align => :right
    end

  end

  def program_board_card_content(pdf, room="<TODO>", hour="99:99 - 99:99")
    pdf.font_size 10
    pdf.text hour, :align => :center
    pdf.move_up 4.mm
    pdf.text id.to_s, :align => :right, :size => 6
    pdf.bounding_box([0, 85.mm], :width => 135.mm) do 
      pdf.text title, :align => :center, :size => 18
      pdf.text sub_title, :align => :center, :style => :italic, :size => 8 if !sub_title.nil?
    end
    pdf.bounding_box([0, 65.mm], :width => 135.mm) do 
      wikinize_for_pdf(short_description, pdf) if !short_description.nil? 
    end
    pdf.bounding_box([0, 10.mm], :width => 135.mm, :height => 12.mm ) do 
      pdf.text "Presenters:"
      pdf.text "Format: "
      pdf.text "Room: "
    end
    pdf.bounding_box([20.mm, 10.mm], :width => 113.mm, :height => 12.mm ) do 
      pdf.text presenter_names
      pdf.text session_type.truncate(60)if !session_type.nil? 
      pdf.text room
    end
    pdf.bounding_box([100.mm, 10.mm], :width => 35.mm, :height => 12.mm ) do 
      pdf.text printable_max_participants, :align => :right
      pdf.text printable_laptops_required, :align => :right
    end
  end

  def generate_program_board_card_pdf(file_name)
    Prawn::Document.generate file_name, 
      :page_size => 'A6', :page_layout => :landscape,
      :top_margin => 3.5.mm, :bottom_margin => 3.5.mm,
      :left_margin => 7.mm, :right_margin => 7.mm do |pdf|
      program_board_card_content(pdf)
    end
  end

  def printable_description_content(pdf, room="<TODO>", hour="99:99 - 99:99")
    pdf.font_size 12
    pdf.text hour, :align => :center
    pdf.move_up 14
    pdf.text id.to_s, :align => :right, :size => 6
    pdf.bounding_box([0, 280.mm], :width => 195.mm) do 
      pdf.text title, :align => :center, :size => 24
      pdf.text sub_title, :align => :center, :style => :italic, :size => 14
    end
    pdf.bounding_box([0, 250.mm], :width => 195.mm) do 
      wikinize_for_pdf(description, pdf)
    end
    pdf.bounding_box([0, 20.mm], :width => 135.mm, :height => 20.mm ) do 
      pdf.text "Presenters:"
      pdf.text "Format: "
      pdf.text "Topic: "
      pdf.text "Room: "
    end
    pdf.bounding_box([25.mm, 20.mm], :width => 110.mm, :height => 20.mm ) do 
      pdf.text presenter_names
      pdf.text session_type.truncate(60) unless session_type.nil? 
      pdf.text topic_name 
      pdf.text room
    end
    pdf.bounding_box([480, 20.mm], :width => 30.mm, :height => 20.mm ) do 
      pdf.text printable_max_participants, :align => :right
      pdf.text printable_laptops_required, :align => :right
    end
  end

  def generate_pdf(file_name)
    Prawn::Document.generate file_name, 
      :page_size => 'A4', :page_layout => :portrait,
      :top_margin => 3.5.mm, :bottom_margin => 3.5.mm,
      :left_margin => 7.mm, :right_margin => 7.mm do |pdf|
      printable_description_content(pdf)
    end
  end

  def self.without_review
    #Session.order('created_at desc').select {|s| s.reviews.empty? }
    Session.all.select {|s| s.reviews.empty? }
  end
  def self.younger_than_a_week
    Session.all.select { |s| s.created_at > Date.today-7 }
  end
  def self.sessions_that_need_a_review
    sessions = (without_review + younger_than_a_week)
    sessions.uniq.sort {|s1,s2| s2.created_at <=> s1.created_at }
  end

end
