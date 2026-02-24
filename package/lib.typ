#import "@preview/cetz:0.4.2"

#let wasm-plugin = plugin("conllu_plugin.wasm")

#let dependency-tree(
  conllu-text, 
  word-spacing: 2.0, 
  level-height: 1.0,
  arc-roundness: 0.18,
  show-upos: false,
  show-xpos: false,
  show-lemma: false,
  show-enhanced-as-dashed: true,
  show-root: true,
  highlights: (:) 
) = {
  let raw-json = wasm-plugin.layout_conllu(bytes(conllu-text))
  let sentences = json(raw-json)

  for sentence in sentences {
    if sentence.text != "" {
      align(center, strong(sentence.text))
      v(0.5em)
    }

    cetz.canvas({
      import cetz.draw: *

      for (i, token) in sentence.tokens.enumerate() {
        let x = float(i) * float(word-spacing)
        let safe-name = "word-" + str(token.id).replace(".", "-")
        
        content((x, 0.0), [#token.form], name: safe-name)
        
        let y-offset = -0.45
        if show-lemma and token.lemma != "_" {
          content((x, y-offset), text(size: 8pt, fill: rgb("555555"), token.lemma))
          y-offset -= 0.35
        }
        if show-upos and token.upos != "_" {
          content((x, y-offset), text(size: 8pt, fill: rgb("0055aa"), token.upos))
          y-offset -= 0.35
        }
        if show-xpos and token.xpos != "_" {
          content((x, y-offset), text(size: 8pt, fill: rgb("aa5500"), token.xpos))
          y-offset -= 0.35
        }
      }

      let global-max-level = 0
      for arc in sentence.arcs {
        if arc.level > global-max-level { global-max-level = arc.level }
      }

      if show-root {
        let root-y = float(global-max-level + 1) * float(level-height)
        for root in sentence.roots {
          let x = float(root.idx) * float(word-spacing)
          
          let is-highlighted = root.dep_id in highlights
          let root-color = if is-highlighted { highlights.at(root.dep_id) } else { black }
          let root-width = if is-highlighted { 1.5pt } else { 0.75pt }
          
          line(
            (x, root-y), (x, 0.3),
            stroke: (paint: root-color, thickness: root-width),
            mark: (end: "stealth", fill: root-color, scale: 0.75),
            name: "root-" + str(root.idx)
          )
          content(
            (x, root-y + 0.15),
            box(
              fill: white, inset: (x: 2pt, y: 1pt), radius: 2pt,
              text(size: 8pt, weight: "bold", fill: root-color, root.label)
            )
          )
        }
      }

      for arc in sentence.arcs {
        let x-start = float(arc.start_idx) * float(word-spacing)
        let x-end = float(arc.end_idx) * float(word-spacing)
        
        let peak-y = float(arc.level) * float(level-height)
        let base-y = 0.3
        
        let ctrl-y = (peak-y - 0.25 * base-y) / 0.75
        let offset = (x-end - x-start) * arc-roundness
        
        let start-pt = (x-start, base-y)
        let end-pt = (x-end, base-y)
        
        let is-highlighted = arc.dep_id in highlights
        
        let stroke-color = if is-highlighted { 
          highlights.at(arc.dep_id) 
        } else if arc.is_enhanced and show-enhanced-as-dashed { 
          rgb("0055aa") 
        } else { 
          black 
        }
        
        let stroke-dash = if arc.is_enhanced and show-enhanced-as-dashed and not is-highlighted { 
          "dashed" 
        } else { 
          "solid" 
        }
        let stroke-width = if is-highlighted { 1.5pt } else { 0.75pt }
        
        let mark-style = (fill: stroke-color, scale: 0.75)
        let mark-arg = if arc.is_head_left {
          (end: "stealth", ..mark-style)
        } else {
          (start: "stealth", ..mark-style)
        }
        
        bezier(
          start-pt, end-pt, (x-start + offset, ctrl-y), (x-end - offset, ctrl-y), 
          stroke: (paint: stroke-color, dash: stroke-dash, thickness: stroke-width),
          mark: mark-arg,
          name: "arc-" + str(arc.start_idx) + "-" + str(arc.end_idx)
        )

        let mid-x = (x-start + x-end) / 2.0
        content(
          (mid-x, peak-y + 0.15), 
          box(
            fill: white, inset: (x: 2pt, y: 1pt), radius: 2pt,
            text(size: 8pt, fill: if is-highlighted { stroke-color } else { luma(30) }, arc.label)
          )
        )
      }
    })
    
    v(2em) 
  }
}