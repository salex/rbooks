module Vfw
  class VfwController < ApplicationController
    before_action :require_book

    def index
    end

    def edit_config
      report = Audit.new
      report.get_audit_config
      @vfwcashconfig = report.audit_yaml
    end

    def update_config
      yaml = params[:yaml].gsub(/\r\n?/, "\n")
      respond_to do |format|
        if  Audit.new.put_audit_config(yaml)
          format.html { redirect_to  vfw_index_path, notice: 'Truestee Audit Confiuration saved' }
        else
          format.html { render :edit_config }
        end
      end
    end

    def trustee_audit
      pdf = TrusteeAudit.new
      send_data pdf.render, filename: "trustee_audit",
        type: "application/pdf",
        disposition: "inline"
    end

    def audit
      # filepath = Rails.root.join("db/yaml","vfwcash.yaml")
      bolq = Date.today.beginning_of_quarter - 3.months
      eolq = bolq.end_of_quarter
      @range = bolq..eolq
      @config = Audit.new.get_audit_config.to_o
      @summary = current_book.accounts.find_by(name:@config.current_assets).family_summary(@range.first,@range.last)
      render layout: 'print'
    end

    private

    def require_book
      redirect_to(books_path, alert:'Current Book is required') if current_book.blank?
      @book = Current.book
    end
  end
end
