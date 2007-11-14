
class PlainAsciiAnalyzer < ::Ferret::Analysis::Analyzer
  include ::Ferret::Analysis
  def token_stream(field, str)
        StopFilter.new(
          StandardTokenizer.new(str) ,
          ["fax", "gsm"]
        )
    # raise #<<<----- is never executed when uncommented !!
  end
end


class Comment < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Content', :foreign_key => :parent_id
  
  # simplest case: just index all fields of this model:
  # acts_as_ferret
  
  # we use :store_class_name => true so that we can use 
  # the multi_search method to run queries across multiple
  # models (where each model has it's own index directory)
  #
  # use the :additional_fields property to specify fields you intend 
  # to add in addition to those fields from your database table (which will be
  # autodiscovered by acts_as_ferret)
  # the :ignore flag tells aaf to not try to set this field's value itself (we
  # do this in our custom to_doc method)
  acts_as_ferret( :store_class_name => true, 
                  :remote           => ENV['AAF_REMOTE'] == 'true',  # for testing drb remote indexing
                  :fields => {
                    :content => { :store => :yes },
                    :author  => { },
                    :added   => { :index => :untokenized, :store => :yes, :ignore => true }
                  }, :ferret => { :analyzer => Ferret::Analysis::StandardAnalyzer.new(['fax', 'gsm', 'the', 'or']) } )
                  #}, :ferret => { :analyzer => PlainAsciiAnalyzer.new(['fax', 'gsm', 'the', 'or']) } )

  # only index the named fields:
  #acts_as_ferret :fields => [:author, :content ]

  # you can override the default to_doc method 
  # to customize what gets into your index. 
  def to_doc
    # doc now has all the fields of our model instance, we 
    # just add another field to it:
    doc = super
    # add a field containing the current time
    doc[:added] = Time.now.to_i.to_s
    return doc
  end
end
