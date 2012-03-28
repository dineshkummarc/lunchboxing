class List
  include DataMapper::Resource

  has n, :location
  belongs_to :user
end
