$(document).ready(function () {
  var history = [];
  var historyCursor = 0;

  $("#input").focus();

  $("#input").keydown(function (event) {
    if (event.keyCode == 13) {
      var text = $("#input").val();

      history.push(text);
      historyCursor = history.length;

      append(text, "input", "> ");
      scrollDown();

      $("#input").val("");

      jQuery.getJSON("eval", { command: text }, function (data) {
        if (data.response !== undefined) {
          append(JSON.stringify(data.response), "response");
        } else if (data.error !== undefined) {
          append(data.error, "error");
        } else if (data.notification !== undefined) {
          append(data.notification, "notification", "", true);
        } else {
          append("Invalid response from TRY-REDIS server.", "error");
        }

        scrollDown();
      });

      return false;
    } else if (event.keyCode == 38) {
      if (historyCursor > 0) {
        var text = history[--historyCursor];
        cursorToEnd($("#input"), escapeHtml(text));
      }

      return false;
    } else if (event.keyCode == 40) {
      if (historyCursor < history.length - 1) {
        var text = history[++historyCursor];
        cursorToEnd($("#input"), escapeHtml(text));
      } else {
        historyCursor = history.length
        $("#input").val("");
      }

      return false;
    }
  });

  $("#toolbar").slideDown(500, function () {
    $("#input").focus();
  });

  function append(str, klass, prefix, isHtml) {
    if (prefix === undefined) {
      prefix = "";
    }

    if (!isHtml) {
      prefix = escapeHtml(prefix);
      str = escapeHtml(str);
    }

    var message =
      '<div class="line ' + klass + '">' +
      '<div class="nopad">' +
      '<span class="prompt">' + prefix + '</span>' +
      str +
      '</div></div>';

    $("#log").append(message);
  };

  function scrollDown() {
    $("#log").attr({ scrollTop: $("#log").attr("scrollHeight") });
  };

  function escapeHtml(str) {
    str = str.replace(/&/g, "&amp;");
    str = str.replace(/</g, "&lt;");
    str = str.replace(/>/g, "&gt;");
    str = str.replace(/\n/g, "<br>");

    return str;
  };

  function cursorToEnd(input, text) {
    input.val(text);
    setCaretToPos(input.get(0), text.length);
  };

  function setSelectionRange(input, selectionStart, selectionEnd) {
    if (input.setSelectionRange) {
      input.focus();
      input.setSelectionRange(selectionStart, selectionEnd);
    } else if (input.createTextRange) {
      var range = input.createTextRange();
      range.collapse(true);
      range.moveEnd('character', selectionEnd);
      range.moveStart('character', selectionStart);
      range.select();
    }
  };

  function setCaretToPos(input, pos) {
    setSelectionRange(input, pos, pos);
  };

});
