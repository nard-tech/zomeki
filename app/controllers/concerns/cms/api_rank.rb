module Cms::ApiRank
  extend ActiveSupport::Concern

  include Rank::Controller::Rank

  included do
  end

  def rank(path:, version:)
    case path.shift
    when 'piece_ranks'; rank_piece_ranks(path: path, version: version)
    else render_404
    end
  end

  def rank_piece_ranks(path:, version:)
    return render_404 if path.present?
    return render_405 unless request.get?
    return render_404 unless version == '20150401'

    piece = Rank::Piece::Rank.where(id: params[:piece_id]).first
    return render(json: {}) unless piece

    begin
      current_item = params[:current_item_class].constantize.find(params[:current_item_id])
    rescue => e
      warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
      return render(json: {})
    end

    term = piece.ranking_term
    target = piece.ranking_target
    ranks = rank_datas(piece.content, term, target, piece.display_count, piece.category_option, nil, nil, nil, current_item)

    result = {}
    result[:ranks] = ranks.map do |rank|
                         {title: rank.page_title,
                            url: "#{request.scheme}://#{rank.hostname}#{rank.page_path}",
                          count: piece.show_count == 0 ? nil : rank.accesses}
                       end
    result[:more] = if (body = piece.more_link_body).present? && (url = piece.more_link_url).present?
                      {body: body, url: url}
                    end

    render json: result
  end
end
