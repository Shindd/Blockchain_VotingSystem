function OnlyOneCheck(checkBox) {
    var obj = document.getElementsByName("voting");
    for (var i = 0; i < obj.length; i++) {
        if (obj[i] != checkBox) {
            obj[i].checked = false;
        }
    }
}

function submitCheck(submit) {

    var obj = document.getElementsByName("voting");
    var cnt = 0;
    for (var i = 0; i < obj.length; i++) {
        if (obj[i].checked == true)
            cnt++;
    }

    if (cnt != 1)
        alert("하나의 후보를 선택해주세요");
    else {

        var chk = confirm("투표하시겠습니까?");

        if (chk) {
            countUp();
            return true;
        }
        else {
            return false;
        }
    }
}
