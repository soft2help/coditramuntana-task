$(async ()=>{
    $(".login").on("click", async ()=>{ 
        await auth.login($("#email").val(), $("#password").val());
        pages.index();
    });
});

