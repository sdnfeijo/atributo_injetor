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