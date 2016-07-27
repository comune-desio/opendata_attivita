# Comune di Desio:: Open Data // Attività

[![Build Status](https://travis-ci.org/comune-desio/opendata_attivita.svg?branch=master)](https://travis-ci.org/comune-desio/opendata_attivita)

- Unione di tutte le attività: [bundle.json](https://github.com/comune-desio/opendata_attivita/blob/build/bundle.json)
- Unione di tutte le attività che presentano le coordinate GPS: [bundle.geojson](https://github.com/comune-desio/opendata_attivita/blob/build/bundle.geojson)
- Attività che non hanno trovato riscontro nella ricerca tramite Google: [googlenotfound.json]( https://github.com/comune-desio/opendata_attivita/blob/master/googlenotfound.json)

## Bundles

Per testare la procedura di unione dei singoli JSON nei bundle, bisogna avere installato l'interprete Ruby (versione 2.3.0) e installare le dipendenze necessarie:

```
bundle install
```

Si può poi invocare lo script di creazione dei bundle:

```
bundle exec ruby build.rb
```

Questo script viene automaticamente eseguito dal servizio [Travis-CI](https://travis-ci.org/comune-desio/opendata_attivita) ogni volta che il repository viene aggiornato.
