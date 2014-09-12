require 'rails_helper'

RSpec.describe ReservedLockersController, :type => :controller do

  let(:valid_attributes) {
    {"size"=> "Large", "number"=>5}
  }

  let(:rec1) {{"size"=> "Small", "number"=>1}}
  let(:rec2) {{"size"=> "Small", "number"=>2}}
  let(:rec3) {{"size"=> "Small", "number"=>3}}
  let(:rec4) {{"size"=> "Small", "number"=>4}}
  let(:rec5) {{"size"=> "Small", "number"=>5}}
  let(:rec1000) {{"size"=> "Small", "number"=>1000}}
  let(:rec2000) {{"size"=> "Regular", "number"=>2000}}
  let(:smalllocker) {{"size"=> "Small"}}
  let(:regularlocker) {{"size"=> "Regular"}}
  let(:largelocker) {{"size"=> "Large"}}

  let(:invalid_attributes) {
    {"size"=>"booga", "number"=>-3}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ReservedLockersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before (:each) do
    ReservedLocker.delete_all
  end

  describe "GET index" do
    it "lists all assigned lockers as @ReservedLockers" do
      locker = ReservedLocker.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:reserved_lockers)).to eq([locker])
    end
  end

  describe "GET show" do
    it "show a single listed reserved locker" do
      locker = ReservedLocker.create! valid_attributes
      get :show, {:id => locker.to_param}, valid_session
      expect(assigns(:reserved_locker)).to eq(locker)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ReservedLocker (count of Lockers goes up by one)" do
        expect {
          post :create, {:reserved_locker => valid_attributes}, valid_session
        }.to change(ReservedLocker, :count).by(1)
      end

      it "assigns a newly created locker as @reserved_locker" do
        post :create, {:reserved_locker => valid_attributes}, valid_session
        expect(assigns(:reserved_locker)).to be_a(ReservedLocker)
        expect(assigns(:reserved_locker)).to be_persisted
      end

      it "redirects to the created reserved_locker" do
        post :create, {:reserved_locker => valid_attributes}, valid_session
        expect(response).to redirect_to(ReservedLocker.last)
      end
    end

    describe "Properly fills lowest available locker" do
      it "creates a reservation where none exist at [1]" do
        post :create, {:reserved_locker => smalllocker}, valid_session
        expect(assigns(:reserved_locker)).to be_persisted
        expect(assigns(:reserved_locker).number).to eq(1)
      end

      it "creates contigious reservations where available where [1] at [2]" do
        post :create, {:reserved_locker => smalllocker}, valid_session
        post :create, {:reserved_locker => smalllocker}, valid_session
        expect(assigns(:reserved_locker)).to be_persisted
        expect(assigns(:reserved_locker).number).to eq(2)
      end

      it "creates a reservation in a gap where intial condition is [1][3] at [2]" do
        ReservedLocker.new(rec1).save
        ReservedLocker.new(rec3).save
        post :create, {:reserved_locker => smalllocker}, valid_session
        expect(assigns(:reserved_locker)).to be_persisted
        expect(assigns(:reserved_locker).number).to eq(2)
      end


      it "creates a reservation at the begining where [2] at [1]" do
        ReservedLocker.new(rec2).save
        post :create, {:reserved_locker => smalllocker}, valid_session
        expect(assigns(:reserved_locker)).to be_persisted
        expect(assigns(:reserved_locker).number).to eq(1)

      end

      it "creates a new regular size reservation at [1001]" do
        post :create, {:reserved_locker => regularlocker}, valid_session
        expect(assigns(:reserved_locker)).to be_persisted
        expect(assigns(:reserved_locker).number).to eq(1001)
      end

      it "creates a new large size reservation at [2001]" do
        post :create, {:reserved_locker => largelocker}, valid_session
        expect(assigns(:reserved_locker)).to be_persisted
        expect(assigns(:reserved_locker).number).to eq(2001)
      end

      it "does create a small reservation where reservations are [1]...[1000] at [1001] (sizes move up)" do
        (1..1000).each do |x|
          ReservedLocker.new({"size"=> "Small", "number"=> x}).save
        end
        post :create, {:reserved_locker => smalllocker}, valid_session
        expect(assigns(:reserved_locker)).to be_persisted
        expect(assigns(:reserved_locker).number).to eq(1001)
      end

      it "does no create a reservation when all are filled" do
        (1..3000).each do |x|
          ReservedLocker.new({"size"=> "Small", "number"=> x}).save
        end
        post :create, {:reserved_locker => smalllocker}, valid_session
        expect(assigns(:reserved_locker).persisted?).to be_falsey
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved locker" do
        post :create, {:reserved_locker => invalid_attributes}, valid_session
        expect(assigns(:reserved_locker)).to be_a_new(ReservedLocker)
      end

      # TODO: Make sure redirect works (outside of scope for now)
      # it "re-renders the 'create' template" do
      #   post :create, {:reserved_locker => invalid_attributes}, valid_session
      #   expect(response).to render_template(:create)
      # end
    end
  end

  describe "DELETE destroy" do
    it "remove reservation" do
      # We remove reservations by locker number
      reserved_locker = ReservedLocker.create! valid_attributes
      expect {
        delete :destroy, {:id => reserved_locker.to_param}, valid_session
      }.to change(ReservedLocker, :count).by(-1)
    end

    it "redirects to the reservations list" do
      reserved_locker = ReservedLocker.create! valid_attributes
      delete :destroy, {:id => reserved_locker.to_param}, valid_session
      expect(response).to redirect_to(action: 'index')
    end
  end
end
