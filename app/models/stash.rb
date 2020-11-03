class Stash < ApplicationRecord
  belongs_to :stashable, polymorphic: true
  serialize :hash_data, Hash

end
