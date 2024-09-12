class Api::V1::ReportController < Api::BaseController
  include PaginationMeta
  include ReadOnly
  READ_OPS = %i[].freeze
  WRITE_OPS = %i[].freeze
  EXECUTE_OPS = %i[].freeze
  ROLES_ACCESS = {
    lps: %i[user]
  }.freeze

  # in this case doesnt make sense because we are using sqlite3
  # around_action :use_read_only_databases, only: [:index, :show]

  ## only allow on token per session
  def lps
    pag = BaseSearch::Pagination.new nil, page_params, {max_per_page: 100, default_per_page: 5, default_page: 1}
    collection, page, per_page, total = Report.call pag.page, pag.per_page

    render json: collection,
      each_serializer: Api::V1::ReportSerializer,
      adapter: :json_api,
      meta: pagination_dict(page, per_page, total),
      status: :ok
  end

  private

  def page_params
    @page_param ||= params.permit(*PAGINATION_PARAMS)
  end
end
