CREATE OR REPLACE VIEW v_p8_kadastraal_perceel_recht
                            AS
  SELECT map.sc_kad_identif AS kadperceelcode ,
    zak.pso_identif         AS subjectid ,
    CASE
      WHEN LENGTH(COALESCE(naam_niet_natuurlijk_persoon,''))>0
      THEN naam_niet_natuurlijk_persoon
      ELSE trim(COALESCE(geslachtsnaam,'')
        ||' '
        ||COALESCE(voorvoegsel,''))
        ||', '
        ||COALESCE ( voornamen,'')
    END                                                                                          AS subject_naam ,
    soort_eigenaar                                                                               AS subject_type ,
    trim(SUBSTR(woonadres, LENGTH(woonadres)-instr(reverse(woonadres),' ')+1,LENGTH(woonadres))) AS subject_woonplaats ,
    COALESCE(TO_CHAR(aandeel_teller),'')
    || '/'
    || COALESCE(TO_CHAR(aandeel_noemer),'') AS aandeel ,
    rechtsvorm                              AS recht_soort ,
    CAST( ingangsdatum_recht AS DATE)       AS datum_ingang ,
    CAST(eindd_recht AS         DATE)       AS datum_eind
  FROM pv_map_i_kpe map
  INNER JOIN pv_info_i_koz_zak_recht zak
  ON map.sc_kad_identif = zak.koz_identif;
  --
  -- materialized versie, verversing om 07:30
  --
  -- DROP MATERIALIZED VIEW vm_p8_kadastraal_perceel_recht;
CREATE MATERIALIZED VIEW vm_p8_kadastraal_perceel_recht REFRESH ON DEMAND START WITH TRUNC ( SYSDATE ) + ( 7.5/24 ) NEXT TRUNC ( SYSDATE ) +1+ ( 7.5/24 )
AS
  SELECT * FROM v_p8_kadastraal_perceel_recht;
  -- indexen
  CREATE INDEX kad_perceel_recht_subjid_idx ON vm_p8_kadastraal_perceel_recht
    (
      subjectid ASC
    );
  CREATE INDEX kad_perceel_recht_kpcode_idx ON vm_p8_kadastraal_perceel_recht
    (
      kadperceelcode ASC
    );