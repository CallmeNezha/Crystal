
const ROOT =           __dirname + '/'
const SOURCE =         ROOT + 'src/'
const LIB =            ROOT + 'lib/'
const THIRDLIB =       ROOT + 'third-party/'
const THREE =          THIRDLIB + 'three/'
const TWEEN =          THIRDLIB + 'tweenjs/'
const EXAMPLES =       ROOT + 'lib/examples/'
const PAGES =          ROOT + 'pages/'
const RENDERERS =      ROOT + 'renderers/'

const CONFIGFILE =     ROOT + 'config.json'

let PATH = {
    ROOT
    , SOURCE
    , LIB
    , THIRDLIB
    , THREE
    , EXAMPLES
    , PAGES
    , RENDERERS
    , CONFIGFILE
    , TWEEN
}


module.exports = {
    PATH
}