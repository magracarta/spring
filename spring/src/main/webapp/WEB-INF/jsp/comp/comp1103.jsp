<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 모두싸인연관팝업 > 대면요청 팝업
-- 작성자 : 이강원
-- 최초 작성일 : 2023-04-21 16:20:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">

    $(document).ready(function () {
      var hpNo = "${inputParam.hp_no}";
      var confirmMsg = `${inputParam.confirm_msg}`;
      $M.setValue("hp_no", hpNo.replaceAll("-", ""));
      $M.setValue("confirm_msg", confirmMsg == '' ? "발송하시겠습니까?" : confirmMsg);
    });

    // 문서발송
    function goSend() {
      var sendCd = 'SECURE_LINK';

      var msg = "고객수신연락처는 필수 입력입니다.";
      var sendValue = $M.getValue("send_hp_no");

      if (sendValue == "") {
        alert(msg);
        return;
      }

      var param = {
        "cust_name": $M.getValue("send_cust_name"),
        "modusign_send_cd": sendCd,
        "modusign_send_value": sendValue
      }

      var confirmMsg = $M.getValue("confirm_msg");
      if(confirm(confirmMsg)) {
        try{
          opener.${inputParam.parent_js_name}(param);
          window.close();
        } catch(e) {
          alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
        }
      }
    }

    // 고객구분변경
    function fnChangeGubun() {
      if("CUST" == $M.getValue("cust_gubun")) {
        $("#cust_name").removeClass("dpn");
        $("hp_no").removeClass("dpn");
        $("#breg_name").addClass("dpn");
        $("breg_hp_no").addClass("dpn");
        $M.setValue("send_cust_name", $M.getValue("cust_name"));
      } else {
        $("#cust_name").addClass("dpn");
        $("hp_no").addClass("dpn");
        $("#breg_name").removeClass("dpn");
        $("breg_hp_no").removeClass("dpn");
        $M.setValue("send_cust_name", $M.getValue("breg_name"));
      }
    }

    //팝업 닫기
    function fnClose() {
      window.close();
    }

  </script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form" style="height : 100%">
  <input type="hidden" name="send_cust_name" value="${inputParam.cust_name}">
  <!-- 팝업 -->
  <div class="popup-wrap width-100per" style="height : 100%">
    <!-- 타이틀영역 -->
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <div class="content-wrap">
      <table class="table-border mt5">
        <colgroup>
          <col width="120px">
          <col width="">
        </colgroup>
        <tbody>
        <tr>
          <th class="text-right">구분</th>
          <td>
            <div class="form-check form-check-inline">
              <input class="form-checck-input" type="radio" id="cust_gubun_cust" name="cust_gubun" value="CUST" checked="checked" onchange="fnChangeGubun()">
              <label for="cust_gubun_cust" class="form-check-label">고객명</label>
              <input class="form-checck-input" type="radio" id="cust_gubun_breg" name="cust_gubun" value="BREG" onchange="fnChangeGubun()">
              <label for="cust_gubun_breg" class="form-check-label">회사명</label>
            </div>
          </td>
        </tr>
        <tr>
          <th class="text-right">고객/회사명</th>
          <td>
            <input type="text" class="form-control" id="cust_name" name="cust_name" value="${inputParam.cust_name}" readonly>
            <input type="text" class="form-control dpn" id="breg_name" name="breg_name" value="${inputParam.breg_name}" readonly>
          </td>
        </tr>
        <tr>
          <th class="text-right">연락처</th>
          <td>
            <input type="text" class="form-control" id="hp_no" name="hp_no" format="phone" maxlength="11" value="${inputParam.hp_no}" readonly>
            <input type="text" class="form-control dpn" id="breg_hp_no" name="breg_hp_no" format="phone" maxlength="11" value="${inputParam.breg_hp_no}" readonly>
          </td>
        </tr>
        </tbody>
      </table>
      <table class="table-border mt5">
        <colgroup>
          <col width="120px">
          <col width="">
        </colgroup>
        <tbody>
          <tr>
            <th class="text-right">고객수신연락처</th>
            <td>
              <input type="text" class="form-control" id="send_hp_no" name="send_hp_no" format="phone" maxlength="11" value="${inputParam.hp_no}">
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