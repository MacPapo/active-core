# Table Helper
module TableHelper
  def sortable_column(column, title, path, frame, current_sort, current_direction)
    direction = (current_sort == column) && (current_direction == 'asc') ? 'desc' : 'asc'
    query = { sort_by: column, direction:, name: params[:name] }

    link_to "#{path}?name=#{query[:name]}&sort_by=#{query[:sort_by]}&direction=#{query[:direction]}", data: { turbo_frame: frame }, class: 'text-decoration-none text-primary' do
      raw(
        "<div class='d-flex align-items-center'>
             <i class='bi bi-arrow-#{current_sort == column && current_direction == 'asc' ? 'up' : 'down'}-circle-fill text-dark'></i>
             <span class='ms-1 fw-semibold'>#{title}</span>
           </div>"
      )
    end
  end
end
