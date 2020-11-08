module Vfw
  class SalesItemsController < ApplicationController
    before_action :set_sales_item, only: [:show, :edit, :update, :destroy, :buy, :bought]

    # GET /sales_items
    # GET /sales_items.json
    def index
      @sales_items = SalesItem.order(:name)
    end

    def liquor
      @sales_items = Liquor.order(:name)
      render :index
    end
    def beer
      @sales_items = Beer.order(:name)
      render :index
    end
    def beverage
      @sales_items = Beverage.order(:name)
      render :index
    end
    def food
      @sales_items = Food.order(:name)
      render :index
    end
    def wine
      @sales_items = Wine.order(:name)
      render :index
    end



    # GET /sales_items/1
    # GET /sales_items/1.json
    def show
    end

    # GET /sales_items/new
    def new
      @sales_item = SalesItem.new
    end

    # GET /sales_items/1/edit
    def edit
    end

    def liquor_update
      Liquor.update_liquor(liquor_params)
      redirect_to liquor_sales_items_path, notice:'Liquor inventory updated'
    end

    def beer_update
      Beer.update_beer(beer_params)
      redirect_to beer_sales_items_path, notice:'Beer inventory updated'
    end

    def buy
    end

    def bought
      case @sales_item.type
      when @sales_item.type.include?("Beer")
        @sales_item.buy_beer(sales_item_params)
        rpath = beer_sales_items_path
        puts "DDDDDDDDDDDD   #{rpath}"
      when @sales_item.type.include?("Liquor")
        @sales_item.buy_liquor(sales_item_params)
        rpath = liquor_sales_items_path
      else
        puts "DDDDDDDDDDDD   #{rpath}"

      end
      respond_to do |format|
        if @sales_item.save
          format.html { redirect_to rpath, notice: 'Sales item was successfully purchased.' }
          format.json { render :show, status: :created, location: @sales_item }
        else
          format.html { render :new }
          format.json { render json: @sales_item.errors, status: :unprocessable_entity }
        end
      end

    end

    # POST /sales_items
    # POST /sales_items.json
    def create
      @sales_item = SalesItem.new(sales_item_params)

      respond_to do |format|
        if @sales_item.save
          format.html { redirect_to @sales_item, notice: 'Sales item was successfully created.' }
          format.json { render :show, status: :created, location: @sales_item }
        else
          format.html { render :new }
          format.json { render json: @sales_item.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /sales_items/1
    # PATCH/PUT /sales_items/1.json
    def update
      respond_to do |format|
        if @sales_item.update(sales_item_params)
          case @sales_item.type
          when 'Vfw::Liquor'
            format.html { redirect_to liquor_sales_items_path, notice: 'Liquor item was successfully updated.' }
          when 'Vfw::Beer'
            format.html { redirect_to beer_sales_items_path, notice: 'Beer item was successfully updated.' }
          when 'Vfw::Bevrage'
            format.html { redirect_to beverage_sales_items_path, notice: 'Beverage item was successfully updated.' }
          when 'Vfw::Food'
            format.html { redirect_to food_sales_items_path, notice: 'Food item was successfully updated.' }
          when 'Vfw::Wine'
            format.html { redirect_to wine_sales_items_path, notice: 'Wine item was successfully updated.' }
          else  
            format.html { redirect_to sales_items_path, notice: 'Sales item was successfully updated.' }
            format.json { render :show, status: :ok, location: @sales_item }
          end
        else
          format.html { render :edit }
          format.json { render json: @sales_item.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /sales_items/1
    # DELETE /sales_items/1.json
    def destroy
      @sales_item.destroy
      respond_to do |format|
        format.html { redirect_to sales_items_url, notice: 'Sales item was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def liquor_inventory
      @liquor =  Liquor.order(:name)
    end
    def liquor_print
      @liquor =  Liquor.order(:name)
    end


    def beer_inventory
      @beer =  Beer.order(:name)
    end
    def beer_print
      @beer =  Beer.order(:name)
    end

    def downloaded
      items_path = Rails.root.join('yaml/inventory/menu-item-detail.csv')
      inventory_path = Rails.root.join('yaml/inventory/inventory-detail.csv')

      io = params[:item_details]
      e = io.read
      csv = e.force_encoding("UTF-8")
      File.write(items_path,csv)
      io = params[:inv_details]
      e = io.read
      csv = e.force_encoding("UTF-8")
      File.write(inventory_path,csv)
      SalesItem.sync
      redirect_to root_path, notice: "Should be downloaded and sync'd"
    end

    # def update_pos
    #   io =  params[:text_field]
    #   e = io.read
    #   csv = e.force_encoding("UTF-8")
    #   SalesItem.update_sales_items(csv)
    #   redirect_to sales_items_path, notice: "Pupdate POS items"
    # end


    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sales_item
        @sales_item = SalesItem.find(params[:id])
      end

      def liquor_params
        if params[:liquor].present?
          params.permit!.to_h
        end
      end

      def beer_params
        if params[:beer].present?
          params.permit!.to_h
        end
      end


      # Only allow a list of trusted parameters through.
      def sales_item_params
        params.require(:vfw_sales_item).permit(:name, :type, :price, :cost, :department, 
          :markup, :quanity, :alert, :size, :cases, :bottles, :bottles_1, :bottles_2, :percent, :total, :purchase_price)
      end
  end
end