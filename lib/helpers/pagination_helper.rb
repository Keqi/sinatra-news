module PaginationHelper
  def link_header
    [first_page, previous_page, next_page, last_page].compact.join(",")
  end

  private

  def last_page
    "<#{url}?page=#{last_page_number}>; rel='last'"
  end

  def first_page
    "<#{url}?page=1>; rel='first'"
  end

  def next_page
    "<#{url}?page=#{page+1}>; rel='next'" unless page == 0 || page == last_page
  end

  def previous_page
    "<#{url}?page=#{page-1}>; rel='prev'" unless page == 0 || page == 1
  end

  def page
    params[:page].to_i
  end

  def url
    request.base_url + request.path
  end

  def last_page_number
    (Story.count/2.0).ceil
  end
end