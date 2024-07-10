class MembershipHistoriesController < ApplicationController
  before_action :set_membership_history, only: %i[ show edit update destroy ]

  # GET /membership_histories or /membership_histories.json
  def index
    @membership_histories = MembershipHistory.all
  end

  # GET /membership_histories/1 or /membership_histories/1.json
  def show
  end

  # GET /membership_histories/new
  def new
    @membership_history = MembershipHistory.new
  end

  # GET /membership_histories/1/edit
  def edit
  end

  # POST /membership_histories or /membership_histories.json
  def create
    @membership_history = MembershipHistory.new(membership_history_params)

    respond_to do |format|
      if @membership_history.save
        format.html { redirect_to membership_history_url(@membership_history), notice: "Membership history was successfully created." }
        format.json { render :show, status: :created, location: @membership_history }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @membership_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /membership_histories/1 or /membership_histories/1.json
  def update
    respond_to do |format|
      if @membership_history.update(membership_history_params)
        format.html { redirect_to membership_history_url(@membership_history), notice: "Membership history was successfully updated." }
        format.json { render :show, status: :ok, location: @membership_history }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @membership_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /membership_histories/1 or /membership_histories/1.json
  def destroy
    @membership_history.destroy!

    respond_to do |format|
      format.html { redirect_to membership_histories_url, notice: "Membership history was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership_history
      @membership_history = MembershipHistory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def membership_history_params
      params.fetch(:membership_history, {})
    end
end
