<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈운영 > 렌탈신청현황 > null > 렌탈어태치먼트 연결
-- 작성자 : 이강원
-- 최초 작성일 : 2023-06-16 11:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		<%-- 여기에 스크립트 넣어주세요. --%>

		var auiGridPopup;

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
			};
			var columnLayout = [
				{
					headerText : "관리번호",
					dataField : "rental_attach_no",
					width : "150",
					style : "aui-center aui-link"
				},
				{
					headerText : "어태치먼트명",
					dataField : "attach_name",
					width : "250",
					style : "aui-left"
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "150",
					style : "aui-center"
				},
				{
					headerText : "일련번호",
					dataField : "product_no",
					width : "200",
					style : "aui-center"
				},
				{
					headerText : "관리센터",
					dataField : "mng_org_name",
					width : "150",
					style : "aui-center"
				},
				{
					headerText : "연결여부",
					dataField : "connect_yn",
					visible : false,
				},
			];

			auiGridPopup = AUIGrid.create("#auiGridPopup", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridPopup, []);
			$("#auiGridPopup").resize();

			// 전체 체크박스 클릭 이벤트 바인딩
			AUIGrid.bind(auiGridPopup, "cellClick", function( event ) {
				if(event.dataField == "rental_attach_no") {
					fnApplyChecked(event.item);
				}
			});
		}

		// 체크 후 적용
		function fnApplyChecked(data) {
			var param = {
				"s_rental_attach_no" : data.rental_attach_no,
				"s_type_or" : "${inputParam.s_type_or}",
				"s_rental_doc_no" : "${inputParam.s_rental_doc_no}",
				"s_mng_org_code" : "${inputParam.s_mng_org_code}",
			};

			var msg = data.connect_yn == "Y" ? "어태치먼트를 교체하시겠습니까?" : "어태치먼트를 연결하시겠습니까?";

			$M.goNextPageAjaxMsg(msg, "/mapi/rent/machine/attach/connect", $M.toGetParam(param), {method : 'post'},
					function(result) {
						if(result.success) {
							try {
								alert("처리가 완료되었습니다.");
								opener.${inputParam.parent_js_name}(data.part_no);
							} catch(e) {
								console.log(e);
								alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
							}
							goSearch();
						};
					}
			)
		}

		function goSearch() {
			var param = {
				s_mng_org_code : "${inputParam.s_mng_org_code}",
				s_rental_doc_no : "${inputParam.s_rental_doc_no}",
				s_connect_yn : "${inputParam.s_connect_yn}",
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGridPopup, result.list);
						};
					}
			)
		}

		// 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body   class="bg-white" >
<!-- 팝업 -->
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<div>
			<!-- 조회결과 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
			</div>
			<!-- /조회결과 -->
			<div style="margin-top: 5px; height: 450px;" id="auiGridPopup" ></div>
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();"  >닫기</button>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- /팝업 -->
</body>
</html>