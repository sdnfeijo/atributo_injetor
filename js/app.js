

let currentAttribute = null
let attributeRepository = []
let savedCollections = []
let activeCollection = null
let currentMode = "create"
let inspectorAttributes = []
let nativeCatalog = []

function initializeRuntime(){

  setTimeout(function(){

    if(window.sketchup){

      sketchup.load_repository()
      sketchup.inspect_component()
      sketchup.load_native_catalog()

    }

  }, 250)

}

window.loadRepository = function(data){

  attributeRepository = data || []

  renderCollection()

}

window.loadCollections = function(data){

  savedCollections = data || []

  renderCollection()

}

function refreshNativeCatalog(){

  if(window.sketchup){

    sketchup.load_native_catalog()

  }

}

window.loadNativeCatalog = function(data){

  nativeCatalog = data || []

  renderNativeCatalog()

}


function renderNativeCatalog(){

  const grid = document.getElementById("nativeCatalogGrid")

  grid.innerHTML = ""

  if(!nativeCatalog || nativeCatalog.length === 0){

    grid.innerHTML =
      '<div class="empty-state">Nenhum item no catálogo nativo.</div>'

    return

  }

  const container = document.createElement("div")

  container.style.display = "grid"
  container.style.gridTemplateColumns = "repeat(3,1fr)"
  container.style.gap = "4px"

  nativeCatalog.forEach(function(native){

    const item = document.createElement("label")

    item.innerHTML =
      '<input class="native-checkbox" type="checkbox" value="' +
      (native.name || "") +
      '"> ' +
      (native.name || "")

    container.appendChild(item)

  })

  grid.appendChild(container)

}


function importNativeAttribute(name){

  if(!name){
    return
  }

  if(window.sketchup){

    sketchup.import_native_attribute(name)

  }

}

function syncCollections(){

  if(window.sketchup){

    sketchup.sync_collections(
      JSON.stringify(savedCollections)
    )

  }

}

function toggleGrid(){

  const grid =
    document.getElementById("nativeCatalogGrid")

  if(grid.style.display === "none"){

    grid.style.display = "grid"

  }else{

    grid.style.display = "none"

  }

}

function selectAllNativeAttributes(){

  document
    .querySelectorAll(".native-checkbox")
    .forEach(function(el){

      el.checked = true

    })

}

function clearNativeAttributes(){

  document
    .querySelectorAll(".native-checkbox")
    .forEach(function(el){

      el.checked = false

    })

}

function refreshInspector(){

  if(window.sketchup){

    sketchup.inspect_component()

  }

}

function toggleDetails(id){

  const details =
    document.getElementById(id)

  if(details.style.display === "block"){

    details.style.display = "none"

  }else{

    details.style.display = "block"

  }

}

function setEditorMode(mode){

  currentMode = mode

  const label =
    document.getElementById("editorMode")

  const button =
    document.getElementById(
      "primaryActionButton"
    )

  if(mode === "create"){

    label.innerHTML = "CREATE MODE"
    button.innerHTML = "Adicionar Atributo"

  }else if(mode === "component"){

    label.innerHTML = "COMPONENT MODE"
    button.innerHTML = "Atualizar Componente"

  }else if(mode === "collection"){

    label.innerHTML = "COLLECTION MODE"
    button.innerHTML = "Atualizar Atributo"

  }

}

function clearEditor(){

  currentAttribute = null

  setEditorMode("create")

  document.getElementById(
    "attributeName"
  ).value = ""

  document.getElementById(
    "attributeLabel"
  ).value = ""

  document.getElementById(
    "attributeUnits"
  ).value = ""

  document.getElementById(
    "attributeFormulaUnits"
  ).value = ""

  document.getElementById(
    "attributeAccess"
  ).value = ""

  document.getElementById(
    "attributeFormLabel"
  ).value = ""

  document.getElementById(
    "attributeOptions"
  ).value = ""

  document.getElementById(
    "attributeValue"
  ).value = ""

  document.getElementById(
    "attributeFormula"
  ).value = ""

  document.getElementById(
    "attributeSource"
  ).value = ""

  document.getElementById(
    "nativeIndicator"
  ).innerText = ""

}

function clearCollectionSelection(){

  document
    .querySelectorAll(".repo-check")
    .forEach(function(el){

      el.checked = false

    })

  activeCollection = null

  renderCollection()

}

function primaryAction(){

  if(currentMode === "create"){

    addAttributeToRepository()

  }else if(currentMode === "component"){

    updateComponentAttribute()

  }else if(currentMode === "collection"){

    updateRepositoryAttribute()

  }

}

function addAttributeToRepository(){

  const data = {

    name:
      document.getElementById(
        "attributeName"
      ).value,

    raw_value:
      document.getElementById(
        "attributeValue"
      ).value,

    formula:
      document.getElementById(
        "attributeFormula"
      ).value,

    value:
      document.getElementById(
        "attributeValue"
      ).value,

    units:"",
    access:"",
    source:"definition"

  }

  if(!data.name){
    return
  }

  const existing =
    attributeRepository.findIndex(
      function(item){

      return item.name === data.name

    })

  if(existing >= 0){

    attributeRepository[existing] = data

  }else{

    attributeRepository.push(data)

  }

  if(window.sketchup){

    sketchup.sync_repository(
      JSON.stringify(attributeRepository)
    )

  }

  renderCollection()

}

function updateRepositoryAttribute(){

  if(!currentAttribute){
    return
  }

  const index =
    attributeRepository.findIndex(
      function(item){

      return item.name ===
        currentAttribute.name

    })

  if(index < 0){
    return
  }

  attributeRepository[index] = {

    ...attributeRepository[index],

    name:
      document.getElementById(
        "attributeName"
      ).value,

    label:
      document.getElementById(
        "attributeLabel"
      ).value,

    units:
      document.getElementById(
        "attributeUnits"
      ).value,

    formulaunits:
      document.getElementById(
        "attributeFormulaUnits"
      ).value,

    access:
      document.getElementById(
        "attributeAccess"
      ).value,

    formlabel:
      document.getElementById(
        "attributeFormLabel"
      ).value,

    options:
      document.getElementById(
        "attributeOptions"
      ).value,

    raw_value:
      document.getElementById(
        "attributeValue"
      ).value,

    value:
      document.getElementById(
        "attributeValue"
      ).value,

    formula:
      document.getElementById(
        "attributeFormula"
      ).value,

    source:
      currentAttribute.source ||
      document.getElementById(
        "attributeSource"
      ).value ||
      "definition"

  }

  if(window.sketchup){

    sketchup.sync_repository(
      JSON.stringify(attributeRepository)
    )

  }

  renderCollection()

}

function updateComponentAttribute(){

  if(!currentAttribute){
    return
  }

  const data = {

    name:
      document.getElementById(
        "attributeName"
      ).value,

    value:
      document.getElementById(
        "attributeValue"
      ).value,

    formula:
      document.getElementById(
        "attributeFormula"
      ).value,

    units:
      currentAttribute.units || "",

    access:
      currentAttribute.access || "",

    source:
      currentAttribute.source || "definition"

  }

  if(window.sketchup){

    sketchup.update_attribute(
      JSON.stringify(data)
    )

  }

}

function getSelectedAttributeNames(){

  const selected = []

  document
    .querySelectorAll(".repo-check")
    .forEach(function(el){

      if(el.checked){

        selected.push(el.value)

      }

    })

  return selected

}

function saveCollection(){

  const selected =
    getSelectedAttributeNames()

  if(selected.length === 0){
    return
  }

  const name =
    prompt("Nome da coleção:")

  if(!name){
    return
  }

  const data = {

    name:name,
    selected:selected

  }

  const existing =
    savedCollections.findIndex(
      function(item){

      return item.name === name

    })

  if(existing >= 0){

    savedCollections[existing] = data

  }else{

    savedCollections.unshift(data)

  }

  syncCollections()

  activeCollection = data

  renderCollection()

}

function updateCollection(){

  if(!activeCollection){
    return
  }

  activeCollection.selected =
    getSelectedAttributeNames()

  syncCollections()

  renderCollection()

}

function loadCollection(collection){

  document
    .querySelectorAll(".repo-check")
    .forEach(function(el){

      el.checked =
        collection.selected.includes(
          el.value
        )

    })

}

function deleteCollection(){

  if(!activeCollection){
    return
  }

  savedCollections =
    savedCollections.filter(
      function(item){

      return item.name !==
        activeCollection.name

    })

  syncCollections()

  activeCollection = null

  renderCollection()

}

function renderCollection(){

  const list =
    document.getElementById(
      "collectionList"
    )

  const currentChecks = {}

  document
    .querySelectorAll(".repo-check")
    .forEach(function(el){

      currentChecks[el.value] =
        el.checked

    })

  list.innerHTML = ""

  savedCollections.forEach(
    function(collection){

    const opened =
      activeCollection &&
      activeCollection.name ===
      collection.name

    const header =
      document.createElement("div")

    header.className =
      "collection-item collection-header"

    header.innerHTML =
      (opened ? "▼ " : "► ") +
      collection.name

    header.onclick = function(){

      if(
        activeCollection &&
        activeCollection.name ===
        collection.name
      ){

        activeCollection = null

      }else{

        activeCollection = collection

        loadCollection(collection)

      }

      renderCollection()

    }

    list.appendChild(header)

    if(opened){

      const preview =
        document.createElement("div")

      preview.className =
        "collection-preview"

      collection.selected.forEach(
        function(attrName){

        const attr =
          attributeRepository.find(
            function(item){

            return item.name ===
              attrName

          })

        if(!attr){
          return
        }

        const item =
          document.createElement("div")

        item.className =
          "collection-preview-item"

        item.innerHTML =

          '<input type="checkbox" checked>' +

          '<span>' +
            attr.name +
          '</span>'

        item.onclick = function(){

          setEditorMode("collection")

          loadAttributeEditor(attr)

        }

        preview.appendChild(item)

      })

      list.appendChild(preview)

    }

  })

  const globalTitle =
    document.createElement("div")

  globalTitle.className =
    "repo-global-title"

  globalTitle.innerHTML =
    "Biblioteca Global"

  list.appendChild(globalTitle)

  attributeRepository.forEach(
    function(attr){

    const item =
      document.createElement("div")

    item.className =
      "collection-item"

    const checked =
      currentChecks[attr.name] || false

    item.innerHTML =

      '<div class="repo-row">' +

        '<input class="repo-check" type="checkbox" value="' + attr.name + '"' +
        (checked ? ' checked' : '') +
        '>' +

        '<span>' +
          attr.name +
          (attr.source === 'dc_native' ? ' [NATIVE]' : '') +
        '</span>' +

      '</div>'

    item.onclick = function(e){

      if(e.target.tagName === "INPUT"){
        return
      }

      setEditorMode("collection")

      loadAttributeEditor(attr)

      document
        .querySelectorAll(
          ".collection-item"
        )
        .forEach(function(el){

          el.classList.remove(
            "collection-selected"
          )

        })

      item.classList.add(
        "collection-selected"
      )

    }

    list.appendChild(item)

  })

}

function applySelectedAttributes(){

  const selected = []

  document
    .querySelectorAll(".native-checkbox")
    .forEach(function(el){

      if(el.checked){

        const nativeRegistry = {

          lenx:{ units:"AUTO_LENGTH", access:"" },
          leny:{ units:"AUTO_LENGTH", access:"" },
          lenz:{ units:"AUTO_LENGTH", access:"" },

          x:{ units:"AUTO_LENGTH", access:"" },
          y:{ units:"AUTO_LENGTH", access:"" },
          z:{ units:"AUTO_LENGTH", access:"" },

          rotx:{ units:"DEGREES", access:"" },
          roty:{ units:"DEGREES", access:"" },
          rotz:{ units:"DEGREES", access:"" },

          copies:{ units:"", access:"" },
          hidden:{ units:"", access:"" },
          onclick:{ units:"", access:"" },

          itemcode:{ units:"", access:"" },
          name:{ units:"", access:"" },
          description:{ units:"", access:"" }

        }

        const nativeDef =
          nativeRegistry[el.value] || {}

        const existing =
          (inspectorAttributes || []).find(
            function(a){

              return a.name === el.value

            })

        selected.push({

          name:el.value,
          value:
            existing
              ? existing.value
              : "",
          formula:
            existing
              ? existing.formula
              : "",
          units:nativeDef.units || "",
          access:nativeDef.access || ""

        })

      }

    })

  document
    .querySelectorAll(".repo-check")
    .forEach(function(el){

      if(el.checked){

        const attr =
          attributeRepository.find(
            function(item){

              return item.name ===
                el.value

            })

        if(attr){

          selected.push(attr)

        }

      }

    })

  if(selected.length === 0){
    console.log("SELECTED", selected)
    console.log("TOTAL", selected.length)
    return
  }

  if(window.sketchup){
    console.log("ENVIANDO PARA RUBY")
    console.log(JSON.stringify(selected))

    sketchup.apply_collection(
      JSON.stringify(selected)
    )

  }

}

function copyInspectorSelectionToRepository(){

  document
    .querySelectorAll(".inspector-check")
    .forEach(function(el){

      if(el.checked){

        const attr =
          inspectorAttributes.find(
            function(item){

            return item.name ===
              el.value

          })

        if(!attr){
          return
        }

        const existing =
          attributeRepository.findIndex(
            function(item){

            return item.name ===
              attr.name

          })

        if(existing >= 0){

          attributeRepository[existing] = attr

        }else{

          attributeRepository.push(attr)

        }

      }

    })

  if(window.sketchup){

    sketchup.sync_repository(
      JSON.stringify(attributeRepository)
    )

  }

  renderCollection()

}

function selectAttribute(attr, element){

  setEditorMode("component")

  currentAttribute = attr

  document
    .querySelectorAll(".attr-label")
    .forEach(function(el){

      el.classList.remove(
        "selected-attr"
      )

    })

  element.classList.add(
    "selected-attr"
  )

  if(window.sketchup){

    sketchup.select_attribute(
      JSON.stringify(attr)
    )

  }

}

window.loadAttributeEditor = function(attr){

  currentAttribute = attr

  document.getElementById(
    "attributeName"
  ).value =
    attr.name || ""

  document.getElementById(
    "attributeLabel"
  ).value =
    attr.label || ""

  document.getElementById(
    "attributeUnits"
  ).value =
    attr.units || ""

  document.getElementById(
    "attributeFormulaUnits"
  ).value =
    attr.formulaunits || ""

  document.getElementById(
    "attributeAccess"
  ).value =
    attr.access || ""

  document.getElementById(
    "attributeFormLabel"
  ).value =
    attr.formlabel || ""

  document.getElementById(
    "attributeOptions"
  ).value =
    attr.options || ""

  document.getElementById(
    "attributeValue"
  ).value =
    attr.raw_value || attr.value || ""

  document.getElementById(
    "attributeFormula"
  ).value =
    attr.formula || ""

  document.getElementById(
    "attributeSource"
  ).value =
    attr.source || ""

  document.getElementById(
    "nativeIndicator"
  ).innerText =
    attr.source === "dc_native" ? "[NATIVE]" : ""

}

window.renderInspector = function(data){

  inspectorAttributes = data

  const table =
    document.getElementById(
      "attrTable"
    )

  table.innerHTML = ""

  if(!data || data.length === 0){

    table.innerHTML =
      '<div class="empty-state">' +
      'Nenhum atributo encontrado.' +
      '</div>'

    return

  }

  data.forEach(function(attr, index){

    const detailId =
      "detail_" + index

    const displayMain =
      (
        attr.formula &&
        attr.formula !== ""
      )
      ? attr.formula
      : (attr.value || "")

    const displayResult =
      (
        attr.formula &&
        attr.formula !== ""
      )
      ? '<div class="attr-result">' +
          (attr.value || "") +
        '</div>'
      : ''

    const row =
      document.createElement("div")

    row.className = "attr-line"

    row.innerHTML =

      '<div class="attr-row">' +

        '<div>' +

          '<input ' +
          'class="inspector-check" ' +
          'type="checkbox" ' +
          'value="' + attr.name + '">' +

        '</div>' +

        '<div class="attr-label">' +

          (attr.name || "") +

        '</div>' +

        '<div class="attr-input">' +

          displayMain +

          displayResult +

        '</div>' +

        '<div ' +
        'class="attr-expand" ' +
        'onclick="toggleDetails(\'' + detailId + '\')">' +

          '▸' +

        '</div>' +

      '</div>' +

      '<div class="attr-details" id="' + detailId + '">' +

        '<div class="detail-line">' +
        '<div class="detail-label">Formula:</div>' +
        '<div>' + (attr.formula || "") + '</div>' +
        '</div>' +

        '<div class="detail-line">' +
        '<div class="detail-label">Valor:</div>' +
        '<div>' + (attr.value || "") + '</div>' +
        '</div>' +

        '<div class="detail-line">' +
        '<div class="detail-label">Bruto:</div>' +
        '<div>' + (attr.raw_value || "") + '</div>' +
        '</div>' +

        '<div class="detail-line">' +
        '<div class="detail-label">Tipo:</div>' +
        '<div>' + (attr.type || "") + '</div>' +
        '</div>' +

        '<div class="detail-line">' +
        '<div class="detail-label">Unidade:</div>' +
        '<div>' + (attr.units || "") + '</div>' +
        '</div>' +

        '<div class="detail-line">' +
        '<div class="detail-label">Origem:</div>' +
        '<div>' + (attr.source || "") + '</div>' +
        '</div>' +

      '</div>'

    const label =
      row.querySelector(".attr-label")

    label.onclick = function(){

      selectAttribute(
        attr,
        label
      )

    }

    table.appendChild(row)

  })

}
