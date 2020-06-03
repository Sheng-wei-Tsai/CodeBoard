class BoardsController < ApplicationController

  before_action :authenticate_user!, only: [:my, :new, :edit, :update, :destroy]
  before_action :find_board, only: [:show, :edit, :update, :destroy]
  before_action :build_board, only: [:new, :create]
  before_action :check_authority, only: [:edit, :update, :destroy]

  def index
    @boards = Board.joins(:cards).distinct('boards.id').page(params[:page]).per(6)

    if params[:search]
      @search_term = params[:search]
      @boards = @boards.search_by_title(@search_term)
    end
  end

  def new; end

  def create
    @board.assign_attributes(board_params)

    if @board.save
      redirect_to board_path(@board.id), notice: 'create successfully!'
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def my
    @board = Board.where(user: current_user)
    redirect_to new_board_path if @board.count == 0
  end

  def update
    if @board.update(board_params)
      redirect_to my_boards_path, notice: 'update successfully!'
    else
      render :edit
    end
  end

  def destroy
    if @board.destroy
      redirect_to my_boards_path, notice: 'deleted!'
    else
      redirect_to my_boards_path
    end
  end

  private
  def check_authority
    redirect_to board_path(id: @board.id), notice: 'check authority error! not owner!' if @board.user_id != current_user.id
  end
  
  def find_board
    @board = Board.find_by(id: params[:id])
  end

  def build_board
    @board = current_user.boards.new
  end

  def board_params
    params.require(:board).permit(:title, :description, :language)
  end

end


