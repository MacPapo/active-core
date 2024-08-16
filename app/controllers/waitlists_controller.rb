# frozen_string_literal: true

class WaitlistsController < ApplicationController
  before_action :set_waitlist, only: %i[ show edit update destroy ]
  before_action :set_activity, only: %i[ new create ]

  # GET /waitlists or /waitlists.json
  def index
    @waitlists = Waitlist.all
  end

  # GET /waitlists/1 or /waitlists/1.json
  def show; end

  # GET /waitlists/new
  def new
    @waitlist = Waitlist.new
  end

  # GET /waitlists/1/edit
  def edit; end

  # POST /waitlists or /waitlists.json
  def create
    name = waitlist_params[:name]
    surname = waitlist_params[:surname]
    phone = Phonelib.parse(waitlist_params[:phone])

    user = User.find_or_create_by!(name: name, surname: surname, phone: phone.e164)
    @waitlist = Waitlist.build(
      user: user,
      activity: @activity
    )

    respond_to do |format|
      if @waitlist.save
        format.html { redirect_to waitlist_url(@waitlist), notice: 'Waitlist was successfully created.' }
        format.json { render :show, status: :created, location: @waitlist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @waitlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /waitlists/1 or /waitlists/1.json
  def update
    respond_to do |format|
      if @waitlist.update(waitlist_params)
        format.html { redirect_to waitlist_url(@waitlist), notice: 'Waitlist was successfully updated.' }
        format.json { render :show, status: :ok, location: @waitlist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @waitlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /waitlists/1 or /waitlists/1.json
  def destroy
    @waitlist.destroy!

    respond_to do |format|
      format.html { redirect_to waitlists_url, notice: 'Waitlist was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_waitlist
    @waitlist = Waitlist.find(params[:id])
  end

  def set_activity
    @activity = Activity.find(params[:activity_id] || waitlist_params[:activity_id])
  end

  # Only allow a list of trusted parameters through.
  def waitlist_params
    params.require(:waitlist).permit(:name, :surname, :phone, :activity_id)
  end
end
