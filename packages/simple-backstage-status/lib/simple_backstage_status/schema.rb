require "dry-schema"

Dry::Schema.load_extensions(:monads)

BackstageStatusServiceStatusSenderSchema = Dry::Schema.Params do
  required(:name).filled(:string)
  required(:status).filled(:string)
  optional(:impact).filled(:string)
  required(:description).filled(:string)
  required(:updated_at).filled(:time)
end

BackstageStatusServiceStatusReceiverSchema = Dry::Schema.Params do
  required(:name).filled(:string)
  required(:status).filled(:string)
  optional(:impact).filled(:string)
  optional(:description).filled(:string)
  optional(:updated_at).filled(:time)
end

BackstageStatusSenderSchema = Dry::Schema.Params do
  required(:services).array(BackstageStatusServiceStatusSenderSchema)
end

BackstageStatusReceiverSchema = Dry::Schema.Params do
  required(:services).array(BackstageStatusServiceStatusReceiverSchema)
end
