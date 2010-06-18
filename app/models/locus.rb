class Locus < ActiveRecord::Base

  validates :code, :format => /^[a-z_]+$/i

  belongs_to :parent, :class_name => 'Locus'

  def to_param
    code
  end

  def self.model_name
    name = 'locus'
    name.instance_eval do
      def plural;
        pluralize;
      end

      def singular;
        singularize;
      end

      def human;
        humanize;
      end
    end
    return name
  end

end
