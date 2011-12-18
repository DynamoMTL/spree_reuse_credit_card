CheckoutController.class_eval do

  require 'card_reuse'

  private

  def before_payment
    current_order.payments.destroy_all if request.put?
    @cards = all_credit_cards_for_user(@order.user)
  end

  # we are overriding this method in order to substitue in the exisiting card information
  def object_params
    # For payment step, filter order parameters to produce the expected nested attributes for a single payment and its source, discarding attributes for payment methods other than the one selected
    if @order.payment?
      if params[:payment_source].present? && source_params = params.delete(:payment_source)[params[:order][:payments_attributes].first[:payment_method_id].underscore]

        if params[:existing_card]
          params[:order][:payments_attributes].first[:source_id] = params[:existing_card]
          params[:order][:payments_attributes].first[:source_type] = 'Creditcard'
        else
          params[:order][:payments_attributes].first[:source_attributes] = source_params
        end

      end
      if (params[:order][:payments_attributes])
        params[:order][:payments_attributes].first[:amount] = @order.total
      end
    end

    params[:order]
  end

end
