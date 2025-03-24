<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 모두싸인연관팝업 > 문서발송 팝업
-- 작성자 : 정선경
-- 최초 작성일 : 2023-04-21 16:20:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">

    $(document).ready(function () {
      var hpNo = "${inputParam.hp_no}";
      $M.setValue("send_hp_no", hpNo.replaceAll("-", ""));
    });

    // 문서발송
    function goSend() {
      var sendCd = $M.getValue("modusign_send_cd");
      var sendValue = "";

      if (sendCd == "") {
        alert("고객수신방법은 필수 입력입니다.");
        return;
      }

      var msg = "고객수신연락처는 필수 입력입니다.";
      if (sendCd == "EMAIL") {
        sendValue = $M.getValue("send_email");
        msg = "고객수신방법이 이메일인 경우 이메일은 필수 입력입니다."
      } else if (sendCd == "KAKAO") {
        sendValue = $M.getValue("send_hp_no");
        msg = "고객수신방법이 카카오톡인 경우 휴대전화번호는 필수 입력입니다."
      }

      if (sendValue == "") {
        alert(msg);
        return;
      }

      var param = {
        "modusign_id": $M.getValue("modusign_id"),
        "modusign_send_value": sendValue
      }

      var confirmMsg ="발송하시겠습니까?";
      $M.goNextPageAjaxMsg(confirmMsg, "/modu/send_doc", $M.toGetParam(param), {method : 'post'},
          function(result) {
            if(result.success) {
              fnClose();
            }
          }
      );

      //팝업 닫기
      function fnClose() {
        window.close();
      }
    }
  </script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form" style="height : 100%">
  <input type="hidden" name="modusign_id" value="${inputParam.modusign_id}">
  <!-- 팝업 -->
  <div class="popup-wrap width-100per" style="height : 100%">
    <!-- 타이틀영역 -->
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <div class="content-wrap">
      <div class="title-wrap mt10">
        <h4>고객수신방법</h4>
      </div>
      <table class="table-border mt5">
        <colgroup>
          <col width="120px">
          <col width="">
        </colgroup>
        <tbody>
          <tr>
            <th class="text-left">
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" id="modusign_send_email" name="modusign_send_cd" value="EMAIL" checked="checked">
                <label for="modusign_send_email" class="form-check-label">이메일</label>
              </div>
            </th>
            <td>
              <input type="text" class="form-control" id="send_email" name="send_email" value="${inputParam.email}">
            </td>
          </tr>
          <tr>
            <th class="text-left">
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" id="modusign_send_kakao" name="modusign_send_cd" value="KAKAO">
                <label for="modusign_send_kakao" class="form-check-label">카카오톡</label>
              </div>
            </th>
            <td>
              <input type="text" class="form-control" id="send_hp_no" name="send_hp_no" value="${inputParam.hp_no}">
            </td>
          </tr>
        </tbody>
      </table>
      <div class="btn-group mt5">
        <div class="right">
          <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
        </div>
      </div>
    </div>
  </div>
  <!-- /팝업 -->
</form>
</body>
</html>