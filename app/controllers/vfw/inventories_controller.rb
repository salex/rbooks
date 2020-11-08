module Vfw
  class InventoriesController < ApplicationController
    before_action :set_inventory, only: [:show, :edit, :update, :destroy]

    # GET /inventories
    # GET /inventories.json
    def index
      @inventories = Inventory.all
    end

    # GET /inventories/1
    # GET /inventories/1.json
    def show
    end

    # GET /inventories/new
    def new
      @inventory = Inventory.new
    end

    # GET /inventories/1/edit
    def edit
    end

    # POST /inventories
    # POST /inventories.json
    def create
      @inventory = Inventory.new(inventory_params)

      respond_to do |format|
        if @inventory.save
          format.html { redirect_to @inventory, notice: 'Inventory was successfully created.' }
          format.json { render :show, status: :created, location: @inventory }
        else
          format.html { render :new }
          format.json { render json: @inventory.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /inventories/1
    # PATCH/PUT /inventories/1.json
    def update
      respond_to do |format|
        if @inventory.update(inventory_params)
          format.html { redirect_to @inventory, notice: 'Inventory was successfully updated.' }
          format.json { render :show, status: :ok, location: @inventory }
        else
          format.html { render :edit }
          format.json { render json: @inventory.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /inventories/1
    # DELETE /inventories/1.json
    def destroy
      @inventory.destroy
      respond_to do |format|
        format.html { redirect_to inventories_url, notice: 'Inventory was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_inventory
        @inventory = Inventory.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def inventory_params
        params.fetch(:inventory, {})
      end
  end
end