<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > GPS관리 > null > GPS 사용이력
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			if ("${inputParam.read_only_yn}" == "Y") {
				$("#_goSave").css("display", "none");
			}
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				editable : true,	
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true
			};
			var columnLayout = [
				{ 
					headerText : "장착일자", 
					dataField : "inst_dt",					
					dataType : "date",
					width : "15%", 
					style : "aui-center",
					required : true,
					editable : false,				
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
// 						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
// 							return fnCheckDate(oldValue, newValue, rowItem);
// 						},
// 						showEditorBtnOver : true
					}
				},
				{
					headerText : "탈거일자", 
					dataField : "un_inst_dt",	
					dataType : "date",
					width : "15%", 
					style : "aui-center",
					required : true,
					editable : false,			
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer",
// 						aliasFunction : function (rowIndex, columnIndex, value, headerText, item ) { // 엑셀, PDF 등 내보내기 시 값 가공 함수
// 							return value.replace('tel', "전화").replace('sms', "SMS").replace('email', "메일").replace('dm', "우편").replace(/,/g, "/");
// 			            }
					}, 
					
					// 왜이렇게 했는지 기억안나지만, yyyy-mm-dd로 안만들어져서 주석함!
					/* labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if($M.getValue("read_only_yn") != "Y") {
							if("" == value || null == value) {
								return '<div>' + '<span style="color:red";>' + $M.getCurrentDate("yyyy-MM-dd") + '</span>' + '</div>';
							}
						    return $M.dateFormat(value, "yyyy-MM-dd");	
						} else {
							return value;
						}
						 
					} */
// 					editRenderer : {
// 						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
// 						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
// 						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
// 						maxlength : 8,
// 						onlyNumeric : true, // 숫자만
// 						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
// 							return fnCheckDate(oldValue, newValue, rowItem);
// 						},
// 						showEditorBtnOver : true
// 					}
				},
				{ 
					headerText : "사용기간", 
					dataField : "use_time",					
					width : "10%", 
					editable : false,
					style : "aui-center",
					dataType : "numeric"
				},
				{ 
					headerText : "장비모델", 
					dataField : "machine_name", 
					width : "15%",  
					editable : false,
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "15%", 
					editable : false,
					style : "aui-center"
				},
				{ 
					headerText : "탈거사유", 
					dataField : "un_inst_remark", 
// 					width : "25%", 
					editable : true,
					style : "aui-left"
				},
				{ 
					dataField : "gps_seq",
					visible : false
				},
				{ 
					dataField : "machine_seq",
					visible : false
				},
				{ 
					dataField : "un_inst_yn",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
			
			// 에디팅 시작 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.dataField == "un_inst_remark") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					var unInstYn = event.item["un_inst_yn"];
					if($M.getValue("read_only_yn") != "Y" && "N" == unInstYn) {
						return true; 
					} else {
						return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
					}
				}
			});
		}
	
		// 저장
		function goSave() {
			var gridFrm = fnChangeGridDataToForm(auiGrid);
			if(0 == gridFrm.length) {
				alert("탈거사유를 입력하세요.");
				return false;
			}
			$M.goNextPageAjaxSave(this_page + "/modify", gridFrm, {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("수정되었습니다");
						opener.location.reload();
						fnClose();
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
<input type="hidden" id="read_only_yn" name="read_only_yn" value="${inputParam.read_only_yn}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
           	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<h4><span class="text-primary">${inputParam.gps_no}</span> 사용이력</h4>
<!-- 				<button type="button" class="btn btn-default" onclick="javascript:go1();"><i class="material-iconsadd text-default"></i> 행추가</button> -->
			</div>	
			<div  id="auiGrid"  style="margin-top: 5px; height: 360px;"></div>
			<div class="btn-group mt10">
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