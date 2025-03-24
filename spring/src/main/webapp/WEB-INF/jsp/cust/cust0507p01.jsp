<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 1:1문의 > 상세
-- 작성자 : 한승우
-- 최초 작성일 : 2023-07-31 09:31:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">
    // 답변첨부파일의 index 변수
    var replyFileIndex = 1;
    // 첨부할 수 있는 파일의 개수
    var fileCount = 5;

    $(document).ready(function() {
      <c:forEach var="askFile" items="${askFileList}">fnPrintAskFile('${askFile.file_seq}', '${askFile.file_name}');</c:forEach>
      <c:forEach var="replyFile" items="${replyFileList}">fnPrintReplyFile('${replyFile.file_seq}', '${replyFile.file_name}');</c:forEach>
      // fnInitBtn();
    });

    // TODO:: 첨부파일 삭제 권한 추가할 것

    // 작성자 또는 권한자가 아니면 첨부파일 삭제 버튼 숨김, 비활성화 (보류)
    <%--function fnInitBtn() {--%>
    <%--  if($M.getValue("reg_mem_no") != $M.getValue("user_mem_no") && '${page.fnc.F00582_001}' != 'Y') {--%>
    <%--    $(".btn-auth").addClass("dpn");--%>
    <%--    $("#_goSearchFile").prop("disabled", true);--%>
    <%--    $(".reg-auth").prop("disabled", true);--%>
    <%--    $("#_goModify").addClass("dpn");--%>
    <%--    $("#_goRemove").addClass("dpn");--%>
    <%--  } else {--%>
    <%--    $("#_goModify").removeClass("dpn");--%>
    <%--    $("#_goRemove").removeClass("dpn");--%>
    <%--  }--%>
    <%--}--%>

    // 문의첨부파일 출력
    function fnPrintAskFile(fileSeq, fileName) {
      var str = '';
      str += '<div class="table-attfile-item file" style="float:left; display:block;">';
      str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
      // str += '<input type="hidden" name="ask_file_seq" value="' + fileSeq + '"/>';
      str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
      str += '</div>';
      $('.ask_file_div').append(str);
    }

    // 답변첨부파일 출력
    function fnPrintReplyFile(fileSeq, fileName) {
      var str = '';
      str += '<div class="table-attfile-item file_' + replyFileIndex + '" style="float:left; display:block;">';
      str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
      str += '<input type="hidden" name="reply_file_seq" value="' + fileSeq + '"/>';
      str += '<button type="button" class="btn-default btn-auth" onclick="javascript:fnRemoveFile(' + replyFileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
      str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
      str += '</div>';
      $('.reply_file_div').append(str);
      replyFileIndex++;
    }

    function goSearchFile(){
      if($("input[name='reply_file_seq']").size() >= fileCount) {
        alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
        return false;
      }
      openFileUploadPanel('setFileInfo', 'upload_type=NOTICE&file_type=both&max_size=2048');
    }

    function setFileInfo(result) {
      fnPrintReplyFile(result.file_seq, result.file_name);
    }

    // 첨부파일 삭제
    function fnRemoveFile(fileIndex, fileSeq) {
      var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
      if (result) {
        $(".file_" + fileIndex).remove();
        $("#file_seq_" + fileIndex).remove();
      } else {
        return false;
      }
    }

    // 공지사항 수정
    function goSave() {
      var frm = document.main_form;

      if($M.getValue("reply_text") == "") {
        alert("답변내용은 필수입력입니다.");
        return false;
      }
      if($M.validation(frm) == false) {
        return;
      };
      var idx = 1;
      $("input[name='reply_file_seq']").each(function() {
        var str = 'file_seq_' + idx;
        if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
          $M.setValue(str, $(this).val());
        }
        idx++;
      });
      for(; idx <= fileCount; idx++) {
        $M.setValue('file_seq_' + idx, 0);
      }
      $M.setValue('file_cnt', fileCount);
      $M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm), {method : 'POST'},
              function(result) {
                if(result.success) {
                  fnClose();
                  if (opener != null && opener.goSearch) {
                    opener.goSearch('');
                  }
                }
              }
      );
    }

    // 닫기
    function fnClose() {
      window.close();
    }

  </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<%--  <input type="hidden" id="cmd" name="cmd" value="U" />--%>
<%--  <input type="hidden" id="c_faq_seq" name="c_faq_seq" value="${result.c_faq_seq}">--%>
  <input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}">
  <input type="hidden" id="c_cs_seq" name="c_cs_seq" value="${result.c_cs_seq}">
  <input type="hidden" id="file_cnt" name="file_cnt">
  <!-- 팝업 -->
  <div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <!-- contents 전체 영역 -->
    <div class="content-wrap">
      <!-- 폼테이블 -->
      <div>
        <table class="table-border">
          <colgroup>
            <col width="100px">
            <col width="">
            <col width="100px">
            <col width="">
            <col width="100px">
            <col width="">
          </colgroup>
          <tbody>
          <tr>
            <th class="text-right">고객명</th>
            <td>
              <input type="text" class="form-control width120px" name="cust_name" id="cust_name" value="${result.cust_name}" readonly="readonly">
            </td>
            <th class="text-right">연락처</th>
            <td>
              <input type="text" class="form-control width120px" name="hp_no" id="hp_no" value="${result.hp_no}" readonly="readonly">
            </td>
            <th class="text-right">등급</th>
            <td>
              <div class="form-row inline-pd">
                <div class="col-5">
                  <input type="text" class="form-control width120px" name="cust_grade_str" id="cust_grade_str" value="${result.cust_grade_str}" readonly="readonly">
                </div>
                <div class="col-5">
                  <input type="text" class="form-control width120px" name="cust_grade_hand_str" id="cust_grade_hand_str" value="${result.cust_grade_hand_str}" readonly="readonly">
                </div>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right">메이커</th>
            <td>
              <input type="text" class="form-control width120px" name="maker" id="maker" value="${result.maker}" readonly="readonly">
            </td>
            <th class="text-right">모델명</th>
            <td>
              <input type="text" class="form-control width120px" name="machine_name" id="machine_name" value="${result.machine_name}" readonly="readonly">
            </td>
            <th class="text-right">차대번호</th>
            <td>
              <input type="text" class="form-control width120px" name="body_no" id="body_no" value="${result.body_no}" readonly="readonly">
            </td>
          </tr>
          <tr>
            <th class="text-right">문의구분</th>
            <td>
              <input type="text" class="form-control width120px" name="c_cs_type_name" id="c_cs_type_name" value="${result.c_cs_type_name}" readonly="readonly">
            </td>
            <th class="text-right">등록일시</th>
            <td>
              <input type="text" class="form-control width140px" value="${result.reg_date}" readonly="readonly">
            </td>
            <th class="text-right">처리일시</th>
            <td>
              <input type="text" class="form-control width140px" name="comp_date" id="comp_date" value="${result.comp_date}" readonly="readonly">
            </td>
          </tr>
          <tr>
            <th class="text-right">처리상태</th>
            <td>
              <input type="text" class="form-control width120px" value="${result.comp_yn == 'Y' ? '답변완료' : '답변대기'}" readonly="readonly">
            </td>
            <th class="text-right">처리자</th>
            <td colspan="3">
              <input type="text" class="form-control width120px" name="comp_mem_name" id="comp_mem_name" value="${result.comp_mem_name}" readonly="readonly">
            </td>
          </tr>
          <tr>
            <th class="text-right">문의첨부파일</th>
            <td colspan="5">
              <div class="table-attfile ask_file_div" style="width:100%;">
                <div class="table-attfile" style="float:left">
                </div>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right">문의내용</th>
            <td colspan="5" class="v-align-top">
              <textarea name="ask_text" id="ask_text" rows="10" cols="100" style="width:100%;" readonly="readonly">${result.ask_text}</textarea>
            </td>
          </tr>
          <tr>
            <th class="text-right">답변첨부파일</th>
            <td colspan="5">
              <div class="table-attfile reply_file_div" style="width:100%;">
                <div class="table-attfile" style="float:left">
                  <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
                  &nbsp;&nbsp;
                </div>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right essential-item">답변내용</th>
            <td colspan="5" class="v-align-top">
              <textarea name="reply_text" id="reply_text" rows="10" cols="100" style="width:100%;">${result.reply_text}</textarea>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
      <!-- /폼테이블 -->
      <!-- 그리드 서머리, 컨트롤 영역 -->
      <div class="btn-group mt5">
        <div class="right">
          <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
        </div>
      </div>
      <!-- /그리드 서머리, 컨트롤 영역 -->
      <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
    </div>
    <!-- /contents 전체 영역 -->
  </div>
  <!-- /팝업 -->
  <input type="hidden" id="file_seq_1" name="file_seq_1"/>
  <input type="hidden" id="file_seq_2" name="file_seq_2"/>
  <input type="hidden" id="file_seq_3" name="file_seq_3"/>
  <input type="hidden" id="file_seq_4" name="file_seq_4"/>
  <input type="hidden" id="file_seq_5" name="file_seq_5"/>
</form>
</body>
</html>
