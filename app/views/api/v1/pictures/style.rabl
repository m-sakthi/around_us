@picture ||= locals[:object]

result = {}
styles = locals[:styles] || AppSettings[:picture][:styles].keys.map(&:to_sym).push(:original)
styles.map{ |style| result[style] = @picture.url(style) }

node false do
  result
end