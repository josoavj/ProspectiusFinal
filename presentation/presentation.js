(function(){
  var cols=[
    {n:"Intéressé",c:"var(--s-int)"},
    {n:"Négociation",c:"var(--s-neg)"},
    {n:"Converti",c:"var(--s-con)"},
    {n:"Perdu",c:"var(--s-per)"}
  ];
  var cards=[
    {t:"Hôtel Lagon Bleu",s:"Antananarivo · Appel à relancer",i:0},
    {t:"Agence Vanilla",s:"Antananarivo · Devis à préparer",i:0},
    {t:"Atelier Sakay",s:"Fianarantsoa · Réunion planifiée",i:1},
    {t:"Coopérative Zébu",s:"Toamasina · Contrat signé",i:2},
    {t:"Boutique Rova",s:"Mahajanga · Sans réponse",i:3}
  ];
  var root=document.getElementById("cols");
  function render(){
    root.innerHTML="";
    cols.forEach(function(col,ci){
      var d=document.createElement("div");
      d.className="col";d.style.setProperty("--c",col.c);
      d.innerHTML="<h4>"+col.n+"</h4>";
      cards.forEach(function(k){
        if(k.i!==ci)return;
        var b=document.createElement("button");
        b.type="button";b.className="card";b.style.setProperty("--c",col.c);
        b.innerHTML=k.t+"<small>"+k.s+"</small>";
        b.setAttribute("aria-label",k.t+", statut "+col.n+". Passer au statut suivant");
        b.onclick=function(){k.i=(k.i+1)%cols.length;render();};
        d.appendChild(b);
      });
      root.appendChild(d);
    });
  }
  render();
})();
