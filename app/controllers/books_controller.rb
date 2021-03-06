class BooksController < ApplicationController

  def index
    @user = current_user
    @book = Book.new
    @books = Book.all

    to = Time.current.at_end_of_day
    from = ( to - 6.day ).at_beginning_of_day
    @books = Book.includes(:favorited_users).
      sort {|a,b|
        b.favorited_users.where(created_at: from..to).size <=>
        a.favorited_users.where(created_at: from..to).size
      }
  end

  def show
    
    @booki = Book.find(params[:id])
    unless ViewCount.find_by(user_id: current_user.id, book_id: @booki.id)
    current_user.view_counts.create(book_id: @booki.id)
    end
    
    #@see = See.find_by(ip: request.remote_ip)
    #if @see
    #  @booki = Book.find(params[:id])
    #else
    #  @booki = Book.find(params[:id])
    #  See.create(ip: request.remote_ip)
    #end
    @book = Book.new
    @user = @booki.user
    @comment = Comment.new
  end


  def edit
    @book = Book.find(params[:id])
    if @book.user == current_user
      render :edit
    else
      redirect_to books_path
    end
  end


  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
       flash[:notice] = "You have updated book successfully."
       redirect_to book_path(@book)
    else
       render :edit
    end
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      flash[:notice] = "You have created book successfully."
      redirect_to book_path(@book)
    else
      @user = current_user
      @books = Book.all
      render :index
    end
  end


  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end


 private

 def book_params
   params.require(:book).permit(:title, :body)
 end

end

