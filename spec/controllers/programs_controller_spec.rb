require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe ProgramsController do
  it_should_behave_like "a guarded resource controller", :maintainer

  context "when logged in" do
    login_as :maintainer

    def valid_attributes
      FactoryGirl.attributes_for :program
    end
  
    let(:program) { FactoryGirl.create :program }
    def create_program
      program
    end
  
    describe "GET index" do
      it "assigns all programs as @programs" do
        create_program
        get :index, {}
        assigns(:programs).should eq([program])
      end
    end
  
    describe "GET show" do
      it "assigns the requested program as @program" do
        get :show, {:id => program.to_param}
        assigns(:program).should eq(program)
      end
    end
  
    describe "GET program_board_cards" do
      it "assigns the requested program as @program" do
        session = FactoryGirl.create :session_with_presenter
        get :show, {:id => program.to_param}
        assigns(:program).should eq(program)
      end
    end

    describe "GET new" do
      it "assigns a new program as @program" do
        get :new, {}
        assigns(:program).should be_a_new(Program)
      end
    end
  
    describe "GET edit" do
      it "assigns the requested program as @program" do
        get :edit, {:id => program.to_param}
        assigns(:program).should eq(program)
      end
    end

    describe "GET export" do
       it "assigns the requested program as @program" do
         program.activate
        get :export
        assigns(:program).should eq(program)
      end
    end
  
    describe "POST create" do
      describe "with valid params" do
        it "creates a new Program" do
          expect {
            post :create, {:program => valid_attributes}
          }.to change(Program, :count).by(1)
        end
  
        it "assigns a newly created program as @program" do
          post :create, {:propile_config => valid_attributes}
          assigns(:program).should be_a(Program)
          assigns(:program).should be_persisted
        end
  
        it "redirects to the program list" do
          post :create, {:propile_config => valid_attributes}
          response.should redirect_to(programs_url)
        end
      end
  
      describe "with invalid params" do
        before do
          # Trigger the behavior that occurs when invalid params are submitted
          Program.any_instance.stub(:save).and_return(false)
        end

        it "assigns a newly created but unsaved program as @program" do
          # Trigger the behavior that occurs when invalid params are submitted
          post :create, {:program => {}}
          assigns(:program).should be_a_new(Program)
        end
  
        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          post :create, {:program => {}}
          response.should render_template("new")
        end
      end
    end
  
    describe "PUT insertSlot" do
      describe "with valid params" do
        it "assigns the requested program as @program" do
          program = Program.create! valid_attributes
          put :insertSlot, {:id => program.to_param, :field => { :before => 1} }
          assigns(:program).should eq(program)
        end
        it "redirects to the program" do
          program = Program.create! valid_attributes
          put :insertSlot, {:id => program.to_param, :field => { :before => 1} }
          response.should redirect_to( :action => 'edit' )
        end
      end
    end
  
    describe "PUT removeSlot" do
      describe "with valid params" do
        it "assigns the requested program as @program" do
          program = Program.create! valid_attributes
          put :removeSlot, {:id => program.to_param, :field => { :slot => 1} }
          assigns(:program).should eq(program)
        end
        it "redirects to the program" do
          program = Program.create! valid_attributes
          put :removeSlot, {:id => program.to_param, :field => { :slot => 1} }
          response.should redirect_to( :action => 'edit' )
        end
      end
    end
  
    describe "PUT insertTrack" do
      describe "with valid params" do
        it "assigns the requested program as @program" do
          program = Program.create! valid_attributes
          put :insertTrack, {:id => program.to_param, :field => { :before => 1} }
          assigns(:program).should eq(program)
        end
        it "redirects to the program" do
          program = Program.create! valid_attributes
          put :insertTrack, {:id => program.to_param, :field => { :before => 1} }
          response.should redirect_to( :action => 'edit' )
        end
      end
    end

    describe "PUT removeTrack" do
      describe "with valid params" do
        it "assigns the requested program as @program" do
          program = Program.create! valid_attributes
          put :removeTrack, {:id => program.to_param, :field => { :track => 1} }
          assigns(:program).should eq(program)
        end
        it "redirects to the program" do
          program = Program.create! valid_attributes
          put :removeTrack, {:id => program.to_param, :field => { :track => 1} }
          response.should redirect_to( :action => 'edit' )
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested program" do
          create_program
          # Assuming there are no other programs in the database, this
          # specifies that the Program created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          Program.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, {:id => program.to_param, :program => {'these' => 'params'}}
        end
  
        it "assigns the requested program as @program" do
          program = Program.create! valid_attributes
          put :update, {:id => program.to_param, :program => valid_attributes}
          assigns(:program).should eq(program)
        end
  
        it "redirects to the program" do
          program = Program.create! valid_attributes
          put :update, {:id => program.to_param, :program => valid_attributes}
          response.should redirect_to( :action => 'edit' )
        end
      end
  
      describe "with invalid params" do
        it "assigns the program as @program" do
          program = Program.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          Program.any_instance.stub(:save).and_return(false)
          put :update, {:id => program.to_param, :program => {}}
          assigns(:program).should eq(program)
        end
  
        it "re-renders the 'edit' template" do
          program = Program.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          Program.any_instance.stub(:save).and_return(false)
          put :update, {:id => program.to_param, :program => {}}
          response.should render_template("edit")
        end
      end
    end
  
    describe "DELETE destroy" do
      it "destroys the requested program" do
        program = Program.create! valid_attributes
        expect {
          delete :destroy, {:id => program.to_param}
        }.to change(Program, :count).by(-1)
      end
  
      it "redirects to the programs list" do
        program = Program.create! valid_attributes
        delete :destroy, {:id => program.to_param}
        response.should redirect_to(programs_url)
      end
    end
  
  end
end
