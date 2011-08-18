module Artists

  JAZZ_ARTISTS = Hash.new
  JAZZ_ARTISTS[:at] = "art_tatum"
  JAZZ_ARTISTS[:as] = "artie_shaw"
  JAZZ_ARTISTS[:bg] = "benny_goodman"
  JAZZ_ARTISTS[:bh] = "billie_holiday"
  JAZZ_ARTISTS[:bb] = "bix_beiderbecke"
  JAZZ_ARTISTS[:bm] = "bennie_moten"
  JAZZ_ARTISTS[:cc] = "charlie_christian"
  JAZZ_ARTISTS[:cp] = "charlie_parker"
  JAZZ_ARTISTS[:cb] = "count_basie"
  JAZZ_ARTISTS[:dg] = "dizzy_gillespie"
  JAZZ_ARTISTS[:dr] = "django_reinhardt"
  JAZZ_ARTISTS[:de] = "duke_ellington"
  JAZZ_ARTISTS[:fh] = "fletcher_henderson"
  JAZZ_ARTISTS[:jj] = "james_p_johnson"
  JAZZ_ARTISTS[:jrm] = "jelly_roll_morton"
  JAZZ_ARTISTS[:la] = "louis_armstrong"
  JAZZ_ARTISTS[:lh] = "lionel_hampton"
  JAZZ_ARTISTS[:odjb] = "original_dixieland_jazz_band"
  JAZZ_ARTISTS[:rn] = "red_norvo"

  def key_to_subdir_name(key)
    value_to_subdir_name(JAZZ_ARTISTS[key.to_sym])
  end

  def value_to_subdir_name(value)
    return '/JAZZ/' + value.to_s.capitalize unless value.to_s.grep(/_/)
    '/JAZZ/' + value.to_s.split("_").map! { |name_component| name_component.capitalize }.join("_")
  end

  def value_to_yaml_file(value)
    return value.to_s.capitalize unless value.to_s.grep(/_/)
    value.to_s.split("_").map! { |name_component| name_component.capitalize }.join("") + '.yml'
  end


end
