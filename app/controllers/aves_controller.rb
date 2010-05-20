class AvesController < ApplicationController

  def index
    @ordines = [
            {:name => 'Anseriformes',
             :familiae => [
                     {:name => 'Anatidae',
                      :species => [
                              {:name => 'Anas prima'},
                              {:name => 'Anas secunda'}]
                     }
                     ]
                     },

            {:name => 'Galliformes',
             :familiae => [
                     :name => 'Phasianidae',
                     :species => [
                             {:name => 'Phasianus colchicus'},
                             {:name => 'Coturnix coturnix'}
                             ]
                     ]
                     }
            ]
#    render
  end
  
end