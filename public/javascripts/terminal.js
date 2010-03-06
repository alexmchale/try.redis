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

  function append(str, klass, prefix) {
    if (prefix === undefined) {
      prefix = "";
    }

    var message =
      '<p class="line">' +
      '<span class="prompt">' + escapeHtml(prefix) + '</span>' +
      '<span class="' + klass + '">' + escapeHtml(str) + '</span>' +
      '</p>'

    $("#log").append(message);
  };

  function scrollDown() {
    $("#log").attr({ scrollTop: $("#log").attr("scrollHeight") });
  };

  function escapeHtml(str) {
    str = str.replace(/&/, "&amp;");
    str = str.replace(/</, "&lt;");
    str = str.replace(/>/, "&gt;");

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
