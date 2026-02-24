#import "lib.typ": dependency-tree

#set page(width: auto, height: auto, margin: 3mm)

#let sample-conllu = ```
# sent_id = 1
# text = They buy and sell books.
1	They	they	PRON	PRP	_	2	nsubj	_	_
2	buy	buy	VERB	VBP	_	0	root	_	_
3	and	and	CCONJ	CC	_	4	cc	_	_
4	sell	sell	VERB	VBP	_	2	conj	_	_
5	books	book	NOUN	NNS	_	2	obj	_	_
6	.	.	PUNCT	.	_	2	punct	_	_
```.text

#dependency-tree(
  sample-conllu, 
  word-spacing: 2.5, 
  show-upos: true,
  show-lemma: true,
  highlights: (
    "2": red,          // Highlight the ROOT arrow pointing to 'buy'
    "5": rgb("aa00ff") // Highlight the arc pointing to 'books'
  )
)