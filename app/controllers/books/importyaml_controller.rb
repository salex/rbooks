class Books::ImportyamlController < BooksController

  def new
    @book = Book.new
    puts "It got here new"
    render template:'books/actions/importyaml'
  end

  def create
    puts "It got here create #{book_params[:name]}"
    # @book = Book.new(book_params)
    ok = ImportYaml.new(book_params[:name],true).import_accounts

    flash.notice = "We need the yaml file then create book and accounts #{ok.ok}"
    redirect_to books_path

  end

end
