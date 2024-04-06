# frozen_string_literal: true

module CorrectableConcern
  SKIP_VALUE = "Skip"
  SAVE_VALUE = "Save"
  SAVE_AND_NEXT_VALUE = "Save and next >>"

  def self.included(klass)
    klass.before_action :extract_correction, only: [:edit, :update]
  end

  private

  def redirect_after_update_path(record)
    if correcting?
      if params[:commit] == SAVE_VALUE
        return [:edit, record, { correction: @correction.id }]
      elsif params[:commit] == SAVE_AND_NEXT_VALUE
        return next_path(record)
      end
    end
    default_redirect_path(record)
  end

  def extract_correction
    @correction = Correction.where(id: params[:correction]).first
  end

  def process_correction_options(record)
    if correcting?
      set_correction_flash(record)
      if params[:commit] == SKIP_VALUE
        redirect_to next_path(record)
      else
        yield
      end
    else
      yield
    end
  end

  def default_redirect_path(_)
    { action: :show }
  end

  def next_path(record)
    if (next_record = @correction.next_after(record))
      [:edit, next_record, { correction: @correction.id }]
    else
      flash[:notice] = "You have reached the last record!"
      [:edit, @correction]
    end
  end

  def set_correction_flash(record) # rubocop:disable Naming/AccessorMethodName
    flash.now.notice = "Remaining to be corrected: #{@correction.after(record).count}" if correcting?
  end
end
