class CategoriesController < ApplicationController
  def index
    @categories = get_all_records("category").select { |category| category['user_id'] == current_user.id.to_s }
  end

  def show
    @category = redis_client.hgetall("category:#{params['id']}")
    month_entries = get_all_records("entry").select { |entry| entry['category_id'] == @category['id'] && entry['date'].to_date.year == Date.current.year && entry['date'].to_date.month == Date.current.month && entry['type_id'] == "1" }
    @expenses_this_month = month_entries.sum { |entry| entry['value'].to_i }
    @entries = get_all_records("entry").select { |entry| entry['category_id'] == @category['id'] }
  end

  def new
  end

  def create
    new_id = redis_client.hmget("next_object_ids", "category")[0] || 1
    redis_client.hmset("next_object_ids", "category", (new_id.to_i + 1))
    redis_client.mapped_hmset("category:#{new_id}", {"id": new_id, "user_id": current_user.id.to_s, "name": category_params['name']})

    redirect_to '/categories'
  end

  def edit
    @category = redis_client.hgetall("category:#{params['id']}")
  end

  def update
    redis_client.mapped_hmset("category:#{params['id']}", category_params)

    redirect_to '/categories'
  end

  def destroy
    redis_client.del("category:#{params['id']}")
    category_entries = get_all_records("entry").select { |entry| entry['category_id'] == params['id'] }
    category_entries.each do |category_entry|
      redis_client.del("entry:#{category_entry['id']}")
    end

    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end

  private

  def get_all_records(record_type, columns = [])
    objects = []
    object_keys = redis_client.keys("#{record_type}:*")
    object_keys.each do |key|
      object = columns.present? ? redis_client.hmget(key, columns) : redis_client.hgetall(key)
      objects.push(object)
    end
    objects
  end

  def redis_client
    Redis.new(host: "redis")
  end

  def category_params
    params.require(:category).permit(Category.allowed_params).to_h
  end
end