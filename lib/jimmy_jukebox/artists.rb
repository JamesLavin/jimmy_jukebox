module Artists

  ARTISTS = {
    acb:   { genre: 'BANJO', name: "archibald_camp_banjo" },
    at:    { genre: 'JAZZ', name: "art_tatum" },
    as:    { genre: 'JAZZ', name: "artie_shaw"},
    bg:    { genre: 'JAZZ', name: "benny_goodman"},
    bh:    { genre: 'JAZZ', name: "billie_holiday"},
    bhc:   { genre: 'ROCK', name: "bill_haley_comets"},
    bb:    { genre: 'JAZZ', name: "bix_beiderbecke"},
    berry: { genre: 'ROCK', name: "chuck_berry"},
    bm:    { genre: 'JAZZ', name: "bennie_moten"},
    bop:   { genre: 'ROCK', name: "big_bopper"},
    ca:    { genre: 'JAZZ', name: "cannonball_adderley"},
    carl:  { genre: 'ROCK', name: 'carl_perkins'},
    cb:    { genre: 'JAZZ', name: "count_basie"},
    cc:    { genre: 'JAZZ', name: "charlie_christian"},
    cp:    { genre: 'JAZZ', name: "charlie_parker"},
    ch:    { genre: 'JAZZ', name: "coleman_hawkins"},
    check: { genre: 'ROCK', name: "chubby_checker"},
    chjb:  { genre: 'JAZZ', name: "clifford_hayes_jug_blowers"},
    cl:    { genre: 'ROCK', name: 'curtis_lee'},
    coast: { genre: 'ROCK', name: 'the_coasters'},
    dx:    { genre: 'JAZZ', name: "dixieland"},
    dg:    { genre: 'JAZZ', name: "dizzy_gillespie"},
    dr:    { genre: 'JAZZ', name: "django_reinhardt"},
    de:    { genre: 'JAZZ', name: "duke_ellington"},
    e:     { genre: 'ROCK', name: 'elvis'},
    eb:    { genre: 'ROCK', name: "everly_brothers"},
    eh:    { genre: 'JAZZ', name: "earl_hines"},
    es:    { genre: 'BLUEGRASS', name: "earl_scruggs"},
    fc:    { genre: 'CLASSICAL', name: "chopin"},
    fh:    { genre: 'JAZZ', name: "fletcher_henderson"},
    fs:    { genre: 'CLASSICAL', name: "franz_schubert"},
    gm:    { genre: 'JAZZ', name: "glenn_miller"},
    h:     { genre: 'CLASSICAL', name: 'haydn'},
    holly: { genre: 'ROCK', name: 'buddy_holly'},
    jb:    { genre: 'CLASSICAL', name: 'johannes_brahms'},
    jc:    { genre: 'JAZZ', name: "john_coltrane"},
    jj:    { genre: 'JAZZ', name: "james_p_johnson"},
    jll:   { genre: 'ROCK', name: "jerry_lee_lewis"},
    jm:    { genre: 'JAZZ', name: "jazz_medleys"},
    jrm:   { genre: 'JAZZ', name: "jelly_roll_morton"},
    jsb:   { genre: 'CLASSICAL', name: "bach"},
    ko:    { genre: 'JAZZ', name: "king_oliver"},
    la:    { genre: 'JAZZ', name: "louis_armstrong"},
    lb:    { genre: 'JAZZ', name: "les_brown"},
    lh:    { genre: 'JAZZ', name: "lionel_hampton"},
    lr:    { genre: 'ROCK', name: 'little_richard'},
    lvb:   { genre: 'CLASSICAL', name: "beethoven"},
    m:     { genre: 'CLASSICAL', name: "mendelssohn"},
    md:    { genre: 'JAZZ', name: "miles_davis"},
    mjq:   { genre: 'JAZZ', name: "modern_jazz_quartet"},
    mon:   { genre: 'BLUEGRASS', name: "bill_monroe"},
    mr:    { genre: 'CLASSICAL', name: "maurice_ravel"},
    odjb:  { genre: 'JAZZ', name: "original_dixieland_jazz_band"},
    op:    { genre: 'JAZZ', name: "oscar_peterson"},
    pw:    { genre: 'JAZZ', name: "paul_whiteman"},
    rb:    { genre: 'ROCK', name: 'the_righteous_brothers'},
    riv:   { genre: 'ROCK', name: "the_rivieras"},
    rn:    { genre: 'JAZZ', name: "red_norvo"},
    ro:    { genre: 'ROCK', name: 'roy_orbison'},
    rt:    { genre: 'JAZZ', name: "ragtime"},
    rv:    { genre: 'ROCK', name: 'richie_valens'},
    sb:    { genre: 'JAZZ', name: "sidney_bechet"},
    sj:    { genre: 'JAZZ', name: "scott_joplin"},
    v:     { genre: 'CLASSICAL', name: "vivaldi"},
    wam:   { genre: 'CLASSICAL', name: "mozart"}
  }

  def artist_genre(key)
    ARTISTS[key][:genre]
  end

  def artist_name(key)
    ARTISTS[key][:name]
  end

  def artist_name_to_genre(name)
    artists = ARTISTS.select { |k,v| v[:name] == name }
    key, value = artists.first
    value[:genre]
  end

  def artist_name_to_subdir_name(name)
    return "/#{artist_name_to_genre(name)}/" + name.to_s.capitalize unless name.to_s.match(/_/)
    "/#{artist_name_to_genre(name)}/" + name.to_s.split("_").map! { |name_component| name_component.capitalize }.join("_")
  end

  def artist_key_to_subdir_name(key)
    artist_name_to_subdir_name(artist_name(key))
  end

  def artist_key_to_yaml_file(key)
    artist_name_to_yaml_file(artist_name(key))
  end

  def artist_name_to_yaml_file(name)
    return name.to_s.capitalize + '.yml' unless name.to_s.match(/_/)
    name.to_s.split("_").map! { |name_component| name_component.capitalize }.join("") + '.yml'
  end

  def prettified_artist_name(name)
    return name.to_s.capitalize unless name.to_s.match(/_/)
    name.to_s.split("_").map! { |name_component| name_component.capitalize }.join(" ")
  end

end
