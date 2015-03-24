_ = require 'underscore'
parser = require '../lib/parser'

describe 'js-parser', ->
  it 'should convert javascript spec source to object', ->
    res = parser.parse '''
      describe('describe 1', function() {
        beforeEach(function() {
        });
        context('context 1', () => {
          it('it 1', function() {});
        });
        it('it 2', function(done) {});
        it('it 3', function() { new Error('err'); });
      });
      describe('describe 2', function() {
        it('it 4', function() {});
      });
    '''

    #console.log JSON.stringify(res, null, 2)

    expected = [
      {
        type: 'describe',
        text: 'describe 1',
        line: 1,
        children: [
          {
            type: 'context',
            text: 'context 1',
            line: 4,
            children: [
              { type: 'it', text: 'it 1', line: 5 }
            ]
          },
          { type: 'it', text: 'it 2', line: 7 },
          { type: 'it', text: 'it 3', line: 8 },
        ]
      },
      {
        type: 'describe',
        text: 'describe 2',
        line: 10,
        children: [
          { type: 'it', text: 'it 4', line: 11 }
        ]
      }
    ]

    expect(_.isEqual(res, expected)).toBe true
