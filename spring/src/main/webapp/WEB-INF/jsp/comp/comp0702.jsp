<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > 공통업무팝업 > null > 거래시필수확인사항
-- 작성자 : 손광진
-- 최초 작성일 : 2020-06-09 10:00:16
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		/* by.재호 */
		/* 커스텀 에디터 스타일 */
		#textAreaWrap {
			font-size: 12px;
			position: absolute;
			height: 100px;
			min-width: 100px;
			background: #fff;
			border: 1px solid #555;
			display: none;
			padding: 4px;
			text-align: right;
			z-index: 9999;
		}

		#textAreaWrap textarea {
			font-size: 12px;
		}
	</style>
	<script type="text/javascript">
		var auiGrid;
		var auiGridBottom;
		var isEditable = false;

		$(document).ready(function() {
			var code = ${SecureUser.org_code}; // 편집가능여부
			if( '${page.fnc.F00225_001}' == 'Y' ) {//2000
				isEditable = true;
			};

			// 그리드 생성
			createAUIGrid();
			createAUIGridBottom();
			
			fnInitTotalCnt();



			// by.재호
			// textarea blur
			$("#myTextArea").blur(function (event) {
				var relatedTarget = event.relatedTarget || document.activeElement;
				var $relatedTarget = $(relatedTarget);

				forceEditngTextArea(this.value);
			});
		});

		// by. 재호
		// 진짜로 textarea 값을 그리드에 수정 적용시킴
		function forceEditngTextArea(value) {
			var dataField = $("#textAreaWrap").data("data-field"); // 보관한 dataField 얻기
			var rowIndex = Number($("#textAreaWrap").data("row-index")); // 보관한 rowIndex 얻기
			value = value.replace(/\r|\n|\r\n/g, "<br/>"); // 엔터를 BR태그로 변환
			//value = value.replace(/\r|\n|\r\n/g, " "); // 엔터를 공백으로 변환

			var item = {};
			item[dataField] = value;

			AUIGrid.updateRow(auiGrid, item, rowIndex);
			$("#textAreaWrap").hide();
		};

		// by. 재호
		// 커스텀 에디팅 렌더러 유형에 맞게 출력하기
		function createMyCustomEditRenderer(event) {

			var dataField = event.dataField;
			var $obj;
			var $textArea;
			//  사용
			if (dataField == "memo_text") {
				$obj = $("#textAreaWrap").css({
					left: event.position.x,
					top: event.position.y,
					width: event.size.width - 8, // 8는 textAreaWrap 패딩값
					height: 120
				}).show();
				$textArea = $("#myTextArea").val(String(event.value).replace(/[<]br[/][>]/gi, "\r\n"));

				// 데이터 필드 보관
				$obj.data("data-field", dataField);
				// 행인덱스 보관
				$obj.data("row-index", event.rowIndex);

				// 포커싱
				setTimeout(function () {
					$textArea.focus();
					$textArea.select();
				}, 16);
			}
		}

		function fnInitTotalCnt() {
			$("#total_cnt").html("${total_cnt}");
			$("#offer_total_cnt").html("${offer_total_cnt}");
		}
		
		// 처리내역 행 추가
		function fnAdd() {
			// 그리드 빈값 체크
			if(fnCheckGridEmpty(auiGrid)) {
	    		var item = new Object();
	    		item.cust_no = "${inputParam.cust_no}";
	    		item.reg_dt = "${inputParam.s_current_dt}";
	    		item.reg_mem_name = "${kor_name}";
	    		item.reg_mem_no = "${SecureUser.mem_no}";
	    		item.memo_text = "";
	    		item.seq_no = 0;
	    		item.cmd = 'C';
				AUIGrid.addRow(auiGrid, item, "first");
			};
		}


		function fnSave(idx, type){
			var columns = ["cust_no", "seq_no", "reg_mem_no","memo_text","upt_date","upt_id"];

			var row = AUIGrid.getItemByRowIndex(auiGrid, idx);
			var frm = $M.createForm();
			frm = fnToFormData(frm, columns, row);

			if (row.cmd == 'C' && type == '03'){ // 저장되지 않은 컬럼
				return AUIGrid.removeRow(auiGrid, idx);
			}

			if ( type != '01' ) { // 종결 / 저장
				var msg = '';
				$M.setHiddenValue(frm, 'cmd', 'U');
				$M.setHiddenValue(frm, 'cust_memo_status_cd', type);
				msg = prompt(type == "02" ? "종결처리": "삭제처리", '');
				if ( msg ){
					$M.setHiddenValue(frm, 'status_memo', msg);
					$M.goNextPageAjax(this_page + "/save", frm, {method : "POST"},
							function(result) {
								if(result.success) {
									location.reload();
								};
							}
					);
				}
			}else {
				$M.setHiddenValue(frm, 'cmd', row.cmd || 'U');
				$M.goNextPageAjaxSave(this_page + "/save", frm, {method : "POST"},
						function(result) {
							if(result.success) {
								location.reload();
							};
						}
				);
			}
		}

		
		// 저장
		// function goSaveMemo() {
		// 	if (fnChangeGridDataCnt(auiGrid) == 0){
		// 		alert("변경된 데이터가 없습니다.");
		// 		return false;
		// 	};
		//
		// 	if (fnCheckGridEmpty() === false) {
		// 		alert("필수 항목은 반드시 값을 입력해야합니다.");
		// 		return false;
		// 	};
		//
		// 	var frm = fnChangeGridDataToForm(auiGrid);
		// 	$M.goNextPageAjaxSave(this_page + "/save", frm, {method : "POST"},
		// 		function(result) {
		// 			if(result.success) {
		// 				location.reload();
		// 			};
		// 		}
		// 	);
		// }
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["memo_text"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		

		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : true,
				showStateColumn : true,
				height : 400,
				wordWrap : true,
				// 고정할 행 높이
				rowHeight : 120,
			};
			
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "등록일자",
				    dataField: "reg_dt",
					dataType : "date",
					formatString : "yyyy/mm/dd",
				    editable : false,
					width : "20%",
					style : "aui-center"
				},
				{
					headerText : "등록자",
					dataField : "reg_mem_name",
				    editable : false,
					width: "10%",
					style : "aui-center"
				},
				{
					headerText : "고객No",
					dataField : "cust_no",
				    editable : false,
					visible : false,
					width: "10%",
					style : "aui-center"
				},
				{
					headerText : "등록자ID",
					dataField : "reg_mem_no",
				    editable : false,
					visible : false,
					width: "10%",
					style : "aui-center"
				},
				{
				    headerText: "메모",
				    dataField: "memo_text",
				    editable : true,
				    wrapText : true,
					width : "60%",
					style : "aui-left",
					renderer: {
						type: "TemplateRenderer"
					},
					editRenderer : {
					      type : "InputEditRenderer",
					      // 에디팅 유효성 검사
					      maxlength : 300,
					      validator : AUIGrid.commonValidator
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(item.reg_mem_no == "${SecureUser.mem_no}" || isEditable) {
		                    return "aui-editable";
		                 };
		                 return "aui-left";
					}
				},
				{ // 삭제를 편집으로 수정 요청 - 류성진 2022.09.21
					headerText : "편집",
					dataField : "seq_no",
					editable : false, // 그리드의 에디팅 사용 안함( 템플릿에서 만든 Select 로 에디팅 처리 하기 위함 )
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						console.log(rowIndex, columnIndex, value, headerText, item)
						// item.reg_mem_no
						var template = '<div>';
						if( isEditable ){
							template += "<button class='btn btn-default' onclick='fnSave(" + rowIndex + ", \"02\")'" + (item.cmd == 'C' ? 'disabled' : '') + ">종결</button>";
							template += "<button class='btn btn-default' onclick='fnSave(" + rowIndex + ", \"01\")'>저장</button>";
							template += "<button class='btn btn-default' onclick='fnSave(" + rowIndex + ", \"03\")'>삭제</button>";
						}else if ( item.reg_mem_no == "${SecureUser.mem_no}") {
							template += "<button class='btn btn-default' onclick='fnSave(" + rowIndex + ", \"02\")'" + (item.cmd == 'C' ? 'disabled' : '') + ">종결</button>";
							template += "<button class='btn btn-default' onclick='fnSave(" + rowIndex + ", \"01\")'>저장</button>";
							template += "<button class='btn btn-default' onclick='fnSave(" + rowIndex + ", \"03\")'>삭제</button>";
						}
						template += '</div>';
						return template;
					},
					style : "aui-center",
					editable : false
				},
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, custMemoListJson);
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.dataField == "memo_text" || event.dataField == "seq_no") {
					// 메모를 등록한 사용자만 수정/삭제 가능
					/*  // 본인이 아닌 사용자도 편집 가능하게 요청사항 - 류성진 2022.09.21
					if(event.item.reg_mem_no == "${SecureUser.mem_no}") {
						// 커스템 에디터 출력
						createMyCustomEditRenderer(event);
						return false;
					} else {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "등록자가 아닌 경우 수정할 수 없습니다.");
						}, 1);
						createMyCustomEditRenderer(event);
						return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
					};*/

					createMyCustomEditRenderer(event);
					return false;
				};
			});
			$("#auiGrid").resize();
		}

		// 그리드생성
		function createAUIGridBottom() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				height : 300,
				wordWrap : true,
				// 고정할 행 높이
				rowHeight : 60,
			};

			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "등록일자",
					dataField: "offer_dt",
					dataType : "date",
					formatString : "yyyy/mm/dd",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width: "10%",
					style : "aui-center"
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					width: "15%",
					style : "aui-center"
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					width: "12%",
					style : "aui-center"
				},
				{
					headerText : "고객No",
					dataField : "cust_no",
					visible : false,
					width: "10%",
					style : "aui-center"
				},
				{
					headerText: "메모",
					dataField: "remark",
					wrapText : true,
					width : "45%",
					style : "aui-left",
					renderer: {
						type: "TemplateRenderer"
					},
				},
			];

			// 그리드 출력
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridBottom, jobOfferListJson);
			$("#auiGridBottom").resize();
		}
		
		function fnList (){
			var param = {
				cust_no : "${inputParam.cust_no}"
			};
			$M.goNextPage('/comp/comp0702p01', $M.toGetParam(param), {popupStatus : getPopupProp(1300, 600)});
		}
		
		//팝업 닫기
		function fnClose() {
			window.close(); 
		}
		
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        	<!-- <h2>거래시 필수확인사항</h2> -->
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">  
			<div class="title-wrap">
				<h4>메모내역</h4>
				<div>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<!-- 상단 그리드 생성 -->
			<div id="auiGrid" style="margin-top: 5px;"></div>		
			
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>						
<%--				<div class="right">--%>
<%--					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>--%>
<%--				</div>--%>
			</div>
			<div class="title-wrap">
				<h4>정비추천</h4>
			</div>
			<!-- 하단 그리드 생성 -->
			<div id="auiGridBottom" style="margin-top: 5px;"></div>
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="offer_total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
	<!-- 사용자 정의 렌더러 - html textarea 태그 -->
	<div id="textAreaWrap">
		<textarea id="myTextArea" class="aui-grid-custom-renderer-ext" style="width:100%; height:90px;"></textarea>
	</div>
</form>
</body>
</html>