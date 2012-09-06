class ProgramEntry < ActiveRecord::Base
  belongs_to :program
  belongs_to :session

  attr_accessible :slot, :track
  attr_accessible :session_id, :program_id
end