Rule     = require('../lib/autoprefixer/rule')
Rules    = require('../lib/autoprefixer/rules')
Selector = require('../lib/autoprefixer/selector')
cases    = require('./lib/cases')
utils    = require('../lib/autoprefixer/utils')

describe 'Rule', ->
  beforeEach ->
    @nodes = cases.load('rule/rule')
    @rules = new Rules(@nodes.stylesheet.rules)
    @rule  = new Rule(@rules, 0, @nodes.stylesheet.rules[0])

  describe 'each()', ->

    it 'iterates over declarations', ->
      decls = []
      @rule.each (i) -> decls.push(i.prop + ' ' + i.value)
      decls.should.eql ['color black', 'top 1px', 'left 2px']

    it 'sets declaration prefix', ->
      nodes = cases.load('rule/prefix')
      rules = new Rules(nodes.stylesheet)
      rule  = new Rule(rules, 0, nodes.stylesheet.rules[0])

      prefixes = []
      rule.each (i, prefix) -> prefixes.push(prefix)
      prefixes.should.eql [undefined, '-webkit-']

    it 'sets keyframes prefix', ->
      nodes = cases.load('rule/prefix')
      rules = new Rules(nodes.stylesheet)
      rule  = new Rule(rules, 0, nodes.stylesheet.rules[0], '-moz-')

      prefixes = []
      rule.each (i, prefix) -> prefixes.push(prefix)
      prefixes.should.eql ['-moz-', '-webkit-']

  describe 'contain()', ->

    it 'checks declarations', ->
      @rule.contain('color').should.be.true
      @rule.contain('position').should.be.false

      @rule.contain('color', 'black').should.be.true
      @rule.contain('color', 'white').should.be.false

  describe 'add()', ->

    it 'adds declaration in interation', ->
      @rule.each (i) => @rule.add(i.number, utils.clone(i.node))
      cases.compare(@nodes, 'rule/double')

  describe 'byProp()', ->

    it 'returns declaration by its property', ->
      @rule.byProp('top').value.should.eql '1px'
      (!!@rule.byProp('position')).should.be.false

  describe 'removeDecl()', ->

    it 'removes declaration in interation', ->
      decls = []

      @rule.each (i) =>
        decls.push(i.prop + ' ' + i.value)
        @rule.removeDecl(i.number) if i.prop == 'top'

      cases.compare(@nodes, 'rule/remove')
      decls.should.eql ['color black', 'top 1px', 'left 2px']

  describe 'prefixSelector()', ->

    it 'clone itself with prefixed selectors', ->
      selector = new Selector('a', ['-moz-', '-webkit-'])
      @rule.prefixSelector(selector)
      cases.compare(@nodes, 'rule/selector')

    it "don't clone twice", ->
      selector = new Selector('a', ['-moz-', '-webkit-'])
      @rule.prefixSelector(selector)
      @rule.prefixSelector(selector)
      cases.compare(@nodes, 'rule/selector')

  describe 'remove()', ->

    it 'removes itself', ->
      @rule.remove()
      @nodes.stylesheet.rules.should.be.empty
