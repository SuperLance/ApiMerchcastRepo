class Api::NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:show, :update, :destroy]
  before_action :set_order, only: [:index, :create]

  # GET /notes
  # GET /notes.json
  def index
    @notes = @order.notes

    render json: @notes
  end

  # GET /notes/1
  # GET /notes/1.json
  def show
    render json: @note
  end

  # POST /notes
  # POST /notes.json
  def create
    @note = Note.new(note_params)
    @order.notes << @note
    @order.user.notes << @note

    if @note.save
      render json: @note, status: :created   # , location: @note
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /notes/1
  # PATCH/PUT /notes/1.json
  def update
    if @note.update(note_params)
      render json: @note
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy
    @note.destroy

    render json: @note
  end

  private

    def set_note
      @note = Note.by_user(current_user).find(params[:id])
    end

    def set_order
      @order = Order.by_user_admin_all(current_user).find(params[:order_id])
    end

    def note_params
      params.require(:note).permit(:text)
    end
end
