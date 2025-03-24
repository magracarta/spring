<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 영업대상고객 > null > 간편고객등록
-- 작성자 : 박준영
-- 최초 작성일 : 2020-07-08 10:10:56
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		var consultTypeCd = ${inputParam.s_consult_type_cd}
	
		$(document).ready(function () {
			createAUIGrid();
		});

		function fnClose() {
			window.close();
		}

		function goNew() {
			if (consultTypeCd != '03') {
				opener.fnSetNewConsult();
			}
			fnClose();
		}

		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "_$uid",
				// rowNumber
				showRowNumColumn: true,
				enableFilter: true,
			};

			var columnLayout = [
				{
					dataField : "replace_consult_seq",
					visible : false
				},
				{
					dataField : "replace_cust_no",
					visible : false
				},
				{
					dataField : "machine_seq",
					visible : false
				},
				{
					dataField : "own_machine_seq",
					visible : false
				},
				{
					headerText: "기종",
					dataField: "machine_name",
					style: "aui-center",
					width: "150",
					editable: false,
					filter: {
						showIcon: true
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						return value == "" ? "상담모델 없음" : value;
					}
				},
				{
					headerText: "차대번호",
					dataField: "body_no",
					style: "aui-center",
					width: "250",
					editable: false,
				},
				{
					headerText: "출고일",
					dataField: "out_dt",
					style: "aui-center",
					width: "80",
					dataType : "date",  
					formatString : "yy-mm-dd",
					editable: false,
				},
				{
					headerText: "최근상담일",
					dataField: "last_consult_dt",
					style: "aui-center",
					width: "80",
					dataType : "date",  
					formatString : "yy-mm-dd",
					editable: false,
				},
				{
					headerText: "최근상담자",
					dataField: "last_consult_mem_name",
					style: "aui-center",
					width: "80",
					editable: false,
				},
				{
					headerText: "상태",
					dataField: "consult_status",
					style: "aui-center aui-popup",
					width: "80",
					editable: false,
				},
				<c:if test="${inputParam.s_consult_type_cd ne '03'}">
				{ 
					headerText : "대차상담", 
					dataField : "",
					width : "80", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							// TODO : 대차상담 - 안건상담등록 호출. 
							// 1. 부모 상담번호 물고 들어감
							// 2. CONSULT_TYPE_CD = '02' (대차)
							// 3. 상담모델 우측에 라디오버튼추가 및 데이터 세팅.
							//     -> O 신차 O 대차 (대차모델명) O 렌탈	
							
							if (event.item.replace_consult_seq == "") {
								opener.fnSetReplaceConsult(event.item);
								window.close();
							} else {
								if (confirm("기존에 대차상담한 이력이 있습니다.\n해당 안건상담상세로 이동하시겠습니까 ?") == false) {
									return false;									
								}
								// TODO : 대차상담건 상세 팝업 띄우기.
								window.close();
								var params = {
									"cust_consult_seq": event.item.replace_consult_seq,
									"cust_no": event.item.replace_cust_no,
								};

								var poppupOption = "";
								$M.goNextPage('/cust/cust0101p01', $M.toGetParam(params), {popupStatus: poppupOption});
							}
							
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '대차상담'
					},
					style : "aui-center",
					editable : false,
				},
				</c:if>
				{
					headerText: "상담번호",
					dataField: "cust_consult_seq",
					visible: false
				},
				{
					headerText: "상담장비번호",
					dataField: "machine_plant_seq",
					visible: false
				},
				{
					headerText: "고객번호",
					dataField: "cust_no",
					visible: false
				}
			];

			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "consult_status") {
					if (consultTypeCd == '03') {
						try {
							opener.fnSetCustConsultRental(event.item);
							window.close();
						} catch (e) {
							alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
						}
					} else {
						try {
							opener.${inputParam.parent_js_name}(event.item);
							window.close();
						} catch (e) {
							alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
						}
					}
				}
			});
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<h4 class="primary">보유 장비명</h4>
			</div>
			<div id="procent_dialog"></div>
			<div style="margin-top: 5px; height: 350px; " id="auiGrid"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="light">
					<div class="left text-warning">
                      	 ※ 대차상담이란 ? 보유장비를 신차로 교체하는경우</br>
                      	 ※ 신차상담이란 ? 신차를 추가로 구매하는 경우
                    </div>					
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /팝업 -->

</form>
</body>
</html>