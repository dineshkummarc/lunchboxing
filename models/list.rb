class List
  include DataMapper::Resource
  
  property :id, Serial
  
  has n, :location
  belongs_to :user
end
