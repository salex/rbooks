class Books::SetupController < BooksController
  before_action :set_book, only: [:show, :edit, :update, :destroy]


  def index
  end

  def show
    if params[:id] == 'clone'
      @accounts = Books::Setup.clone_book_tree
    else
      file_name = params[:id]+'.csv'
      arr = Books::Setup.parse_csv(file_name)
      @accounts = arr[0]
      @tree = arr[1]
    end
  end

  def new
    if params[:option] == 'clone'
      @accounts = Books::Setup.clone_book_tree
      @book = Book.new(root:params[:option])
    else
      file_name = params[:option]+'.csv'
      arr = Books::Setup.parse_csv(file_name)
      @accounts = arr[0]
      @tree = arr[1]
      # this is going to call the create action in Book, not setup
      @book = Book.new(root:params[:option])
    end

  end

  private
  def set_book
  end
    

end