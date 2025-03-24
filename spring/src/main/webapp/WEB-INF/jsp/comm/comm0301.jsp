<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 영업 > 장비어테치먼트관리 > null > null
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-03-27 16:27:52
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

	// 사용 여부
	var ynList = [ {"code_value":"Y", "code_name" : "Y"}, {"code_value" :"N", "code_name" :"N"}];
	
	//출하 시 지급품 목록
	var optionYN = [{"key":"Y", "value" : "기본옵션"}, {"key" :"N", "value" :"추가옵션"}];
	var selectMachineName; // 선택된 모델 이름
	var selectMakerName; // 선택된 메이커 이름
	
	var machinePlantSeq = '${inputParam.machine_plant_seq}'; // url param
	var machineName = '${inputParam.machine_name}' // url param
	var isPageInit = false; // 페이지 첫 초기화 여부

	$(document).ready(function() {
		createAUIGridLeft();
		createAUIGridRight();

		// by.재호
		// textarea blur
		$("#myTextArea").blur(function (event) {
			forceEditngTextArea(this.value);
		});
		
		// inputParam 에 machinePlantSeq 가 있으면 화면 셋팅
		if(machinePlantSeq && machineName) {
			$M.setValue('s_machine_name', machineName)
			goSearch();
		}
	});

	// 엑셀 다운로드
	function fnDownloadExcel() {
		  fnExportExcel(auiGridLeft, "장비어테치먼트관리");
	}

	// 엑셀 다운로드
	function fnExcelDownSec() {
		  fnExportExcel(auiGridRight, "장비어테치먼트옵션");
	}

	// 엔터키 이벤트
	function enter(fieldObj) {
       var field = [ "s_maker_cd", "s_machine_name" ];
       $.each(field, function() {
          if (fieldObj.name == this) {
             goSearch(document.main_form);
          }
       });
    }

	// by. 재호
	// 진짜로 textarea 값을 그리드에 수정 적용시킴
	function forceEditngTextArea(value) {
		var dataField = $("#textAreaWrap").data("data-field"); // 보관한 dataField 얻기
		var rowIndex = Number($("#textAreaWrap").data("row-index")); // 보관한 rowIndex 얻기
		value = value.replace(/\r|\n|\r\n/g, "<br/>"); // 엔터를 BR태그로 변환
		//value = value.replace(/\r|\n|\r\n/g, " "); // 엔터를 공백으로 변환

		var item = {};
		item[dataField] = value;

		AUIGrid.updateRow(auiGridRight, item, rowIndex);
		$("#textAreaWrap").hide();
	}

	// by. 재호
	// 커스텀 에디팅 렌더러 유형에 맞게 출력하기
	function createMyCustomEditRenderer(event) {

		var dataField = event.dataField;
		var $obj;
		var $textArea;
		//  사용
		if (dataField == "remark") {
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

	// 파일 업로드
	function goUploadImg(rowIndex) {
		$M.setValue("row_index", rowIndex);
		var param = {
			'upload_type': 'ATTACH',
			'max_height': '225',
			'max_width': '225',
			'file_type': 'img',
		};
		openFileUploadPanel('setSaveFileInfo', $M.toGetParam(param));
	}

	// 파일 미리보기 and 수정 기능
	function fnPreview(fileSeq, rowIndex) {
		$M.setValue("row_index", rowIndex);
		var param = {
			'upload_type': 'ATTACH',
			'max_height': '225',
			'max_width': '225',
			'file_type': 'img',
			"file_seq" : fileSeq,
		};
		openFileUploadPanel('setSaveFileInfo', $M.toGetParam(param));
	}

	// 파일 콜백
	function setSaveFileInfo(result) {
		AUIGrid.updateRow(auiGridRight, { "file_seq" : result.file_seq, file_name: result.file_name}, $M.getValue('row_index'));
	}

	// 파일 삭제
	function fnRemoveFile(rowIndex) {
		AUIGrid.updateRow(auiGridRight, { "file_seq" : '0', file_name: ''}, rowIndex);
	}
	
	// 모델 클릭 이벤트
	function onClickModel(item) {
		var s_machine_plant_seq = item.machine_plant_seq;
		goSearchAttachment(s_machine_plant_seq);
		$M.setValue("machine_plant_seq", s_machine_plant_seq);
		selectMachineName = item.machine_name;
		selectMakerName = item.maker_name;
	}
	
	// 왼쪽 그리드 생성
	function createAUIGridLeft() {
		var gridPros = {
			rowIdField : "machine_plant_seq",
			// 칼럼 상태 표시
			showStateColumn:true,
			// 삭제 예정 설정
			softRemoveRowMode: true,
		};
		var columnLayout = [
			{ 
				dataField : "machine_plant_seq", 
				visible : false
			},
			{ 
				headerText : "메이커", 
				dataField : "maker_name", 
				style : "aui-center",
				width : "20%"
			},
			{ 
				headerText : "모델", 
				dataField : "machine_name",
				style : "aui-center aui-link",
				width : "20%"
			},
			{ 
				headerText : "품명", 
				dataField : "part_names", 
				style : "aui-left",
				width : "50%"
			},
			{
				headerText : "사용여부",
				dataField : "use_yn",
				style : "aui-center",
				width : "10%",
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : ynList,
					keyField : "code_value",
					valueField : "code_name"
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<ynList.length; i++){
						if(value == ynList[i].code_value){
							return ynList[i].code_name;
						}
					}
					return value;
				}
			}
		];
		auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
		AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
			if (event.dataField == "machine_name") {
				// var s_machine_plant_seq = event.item.machine_plant_seq;
				// goSearchAttachment(s_machine_plant_seq);
				// $M.setValue("machine_plant_seq", s_machine_plant_seq);
				// selectMachineName = event.item.machine_name;
				// selectMakerName = event.item.maker_name;

				onClickModel(event.item);
			}
		});
		AUIGrid.setGridData(auiGridLeft, []);
	}

	// 오른쪽 그리드 생성
	function createAUIGridRight() {
		var gridPros = {
			showRowNumColumn: true,
			enableSorting : false,
			rowIdField : "_$uid",
			editable : true,
			// 칼럼 상태 표시
			showStateColumn:true,
			wordWrap : true,
		};

		var columnLayout = [
			{ 
				headerText : "메이커", 
				dataField : "maker_name", 
				style : "aui-center",
				// width : "15%",
				editable: false
			},
			{ 
				headerText : "모델", 
				dataField : "machine_name", 
				style : "aui-center",
				// width : "15%",
				editable: false
			},
			{
				headerText : "품번",
				dataField : "part_no",
				style : "aui-left",
				width : "200",
				editable: false
			},
			{ 
				headerText : "품명", 
				dataField : "part_name", 
				style : "aui-left",
				width : "200",
				editable: false
			},
			{
				headerText : "옵션구분",
				dataField : "base_yn",
				style : "aui-editable",
				renderer : {
					type : "DropDownListRenderer",
					list : optionYN,
					keyField : "key",
					valueField : "value",
				},
				editable : true,
			},
			{
				headerText : "부품마스터적용",
				dataField : "master_price_yn",
				minWidth : "45",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				},
			},
			{
				headerText : "마스터원가",
				dataField : "in_stock_price",
				style : "aui-right",
				dataType : "numeric",
				editable: false
			},
			{
				headerText : "마스터단가",
				dataField : "vip_sale_price",
				style : "aui-right",
				dataType : "numeric",
				editable: false
			},
			{ 
				headerText : "전략가", 
				dataField : "part_amt",
				style : "aui-right aui-editable",
				dataType : "numeric",
				required : true,
				editable: true,
				styleFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					return item.master_price_yn == "Y" ? "cancelPrice" : "";
				},
			},
			{
				headerText : "어테치먼트 한글명",
				dataField : "attach_kor_name",
				style : "aui-left aui-editable",
				width : "200",
				editable: true,
			},
			{
				headerText: "어테치먼트 대표이미지",
				dataField: "file_seq",
				width : "200",
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
				labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
					if(item.file_seq == 0) {
						return '<button type="button" class="btn btn-default" style="width: 90%" onclick="javascript:goUploadImg(' + rowIndex + ');">이미지등록</button>';
					} else {
						var template = 
							'<div>' +
								'<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fnPreview(' + item.file_seq + ',' + rowIndex  + ');">' + item.file_name + '</span>' +
								'<button type="button" class="btn-default ml5" onclick="javascript:fnRemoveFile(' + rowIndex + ')"><i class="material-iconsclose font-18 text-default"></i></button>' +
							'</div>' 
						return template;
					}
				},
				style: "aui-center",
				editable: false
			},
			{
				headerText: "파일 이름",
				dataField: "file_name",
				visible : false,
			},
			{
				headerText: "상세설명",
				dataField: "remark",
				editable : true,
				wrapText : true,
				width : "300",
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
					return "aui-editable";
				}
			},
			{ 
				headerText : "정렬순서", 
				dataField : "sort_no",
				style : "aui-center aui-editable",
				editable: true
			},
			{
				dataField: "removeBtn",
				headerText: "삭제",
				// width: "50",
				renderer: {
					type: "ButtonRenderer",
					onClick: function (event) {
						AUIGrid.removeRow(auiGridRight, event.rowIndex);
					}
				},
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					return '삭제'
				},
				style: "aui-center",
				editable: false,
				filter: {
					showIcon: true
				},
			}
		];

		auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
		AUIGrid.bind(auiGridRight, "cellEditBegin", function(event) {
			if(event.dataField == "remark") {
				createMyCustomEditRenderer(event);
				return false;
			}
		});

		// 그리드 갱신
		AUIGrid.setGridData(auiGridRight, []);
	}

	// 장비 조회
	function goSearch() {
		var param = {
			"s_maker_cd" : $M.getValue("s_maker_cd"),
			"s_machine_name" : $M.getValue("s_machine_name"),
			"s_use_yn" : $M.getValue("s_use_yn")
		};
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					if(result.list.length == 0) {
						alert("검색된 결과가 없습니다.");
					}
					
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGridLeft, result.list);
					
					// url param 에 machine_plant_seq 가 있고 && 페이지 초기화 전이라면
					if (machinePlantSeq && !isPageInit) {
						result.list.filter(item => item.machine_plant_seq.toString() === machinePlantSeq)?.map(item2 => {
							onClickModel(item2);
							isPageInit = true;
						})
					} else {
						$M.setValue("machine_plant_seq", "");
						AUIGrid.setGridData(auiGridRight, []);
						$("#auiGridRight").resize();
					}
				}
			}
		);
	}
	
	// 장비어테치먼트 조회
	function goSearchAttachment(machine_plant_seq) {
		$M.goNextPageAjax(this_page + "/search/"+machine_plant_seq, '', {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGridRight, result.list);
				}
			}
		);
	}

	// 행추가
	function fnAdd() {

		var machineName = $M.getValue("machine_plant_seq");
		if(machineName == "" || machineName == "undefined") {
			alert("장비 모델을 선택하고 부품 조회를 진행해주세요.");
			return;
		}
		openSearchPartPanel('setPartInfo', 'Y');
	}
	
	//부품조회 창 열기
	function goPartList() {
		var machineName = $M.getValue("machine_plant_seq");
		if(machineName == "" || machineName == "undefined") {	
			alert("장비 모델을 선택하고 부품 조회를 진행해주세요.");
			return;	
		}
		openSearchPartPanel('setPartInfo', 'N');
	}
	
	// 입력폼에 부품정보 입력
	function setPartInfo(rowArr) {

		for(var i = 0; i < rowArr.length; i++) {
			var row = rowArr[i];

			// 2024-08-27 황빛찬 (Q&A:23877) : 모델의 메이커와 부품의 메이커가 달라도 부품 추가될수있도록 수정요청건
			// if(row.maker_name != selectMakerName) {
			// 	setTimeout(function () {
			// 		alert("선택된 메이커와 호환되지 않는 부품입니다.");
			// 	}, 16);
			// 	return;
			// }

			if (isGridData(auiGridRight, "part_no", row.part_no)) {
				return;
			}

			var item = new Object();

			item.part_no = row.part_no;
			item.machine_plant_seq = $M.getValue("machine_plant_seq");
			// item.maker_name = selectMakerName;
			item.maker_name = row.maker_name;
			item.machine_name = selectMachineName;
			item.part_name = row.part_name;
			item.part_price = row.part_price
			item.base_yn = 'Y';
			item.sort_no = '0';
			item.in_stock_price = row.in_stock_price;
			item.vip_sale_price = row.vip_sale_price;
			item.master_price_yn = 'N';
			item.attach_kor_name = row.part_name;
			item.file_seq = '0';
			item.file_name = '';

			AUIGrid.addRow(auiGridRight, item, 'last');
		}
	}
	
	// 어테치먼트 저장
	function goSave() {
		var machine_plant_seq = $M.getValue("machine_plant_seq");
		if(machine_plant_seq == "") {
			alert("장비모델을 선택해주세요.");
			return;
		}
		var frm = document.main_form;
		if($M.validation(frm) == false) { 
			return;
		}
		

		var isValid = AUIGrid.validation(auiGridRight);
		if (!isValid) {
			return;
		}

		if (fnChangeGridDataCnt(auiGridRight) == 0) {
			alert("변경된 데이터가 없습니다.");
			return false;
		}
		
		var frm = fnChangeGridDataToForm(auiGridRight);
		$M.setValue(frm, "machine_plant_seq", machine_plant_seq);

		$M.goNextPageAjaxSave(this_page + '/save', frm , {method : 'POST'},
			function(result) {
				if(result.success) {
					goSearchAttachment(machine_plant_seq);
				}
			}
		);
	}
	
	// 어테치먼트 삭제
	function goRemove() {
		if($M.getValue("machine_plant_seq") == "") {
			alert("장비모델을 선택해주세요.");
			return;
		}
		if (!isGridData(auiGridRight, "part_no", $M.getValue("part_no"))) {
			alert("옵션목록에서 선택해주세요.");
			return;
		}
		var frm = document.main_form;
		if($M.validation(frm, {field:["machine_plant_seq", "part_no"]}) == false) {
			return;
		}
		var param = {
				"machine_plant_seq" : $M.getValue("machine_plant_seq"),
				"part_no" : $M.getValue("part_no")
		}
		$M.goNextPageAjaxRemove(this_page + "/remove", $M.toGetParam(param), { method : "POST"},
			function(result) {
				if(result.success) {
					goSearchAttachment($M.getValue("machine_plant_seq"));
				}
			}
		);
	}
	
	// 그리드에 포함된 값인지
	function isGridData(auiGrid, column, value) {
		var uniqueValues = AUIGrid.getColumnDistinctValues(auiGrid, column);
		for (var i in uniqueValues) {
			if (value == uniqueValues[i]) {
				return true;
			}
		}
		return false;
	}

	// 계약품의서 동기화
	function goSyncData() {
		var machinePlantSeq = $M.getValue("machine_plant_seq");
		if(machinePlantSeq == "") {
			alert("장비모델을 선택해주세요.");
			return;
		}

		// 계약품의서 동기화 팝업 호출
		var popupOption = "";
		var params = {
			"machine_plant_seq" : machinePlantSeq,
		};
		$M.goNextPage('/comm/comm0301p01', $M.toGetParam(params), {popupStatus : popupOption});
	}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="" required="required" alt="장비"/>
<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents">
					<div class="row">
						<!-- 검색영역 -->
						<div class="search-wrap">
							<table class="table">
								<colgroup>
									<col width="50px">
									<col width="100px">
									<col width="40px">
									<col width="100px">
									<col width="60px">
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th>메이커</th>
										<td>
											<select class="form-control" id="s_maker_cd" name="s_maker_cd">
												<option value="">- 전체 -</option>
												<c:forEach items="${codeMap['MAKER']}" var="item">
													<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
														<option value="${item.code_value}">${item.code_name}</option>
													</c:if>
												</c:forEach>
											</select>
										</td>
										<th>모델</th>
										<td>
											<input type="text" class="form-control" id="s_machine_name" name="s_machine_name">
										</td>
										<th>사용여부</th>
										<td>
											<select id="s_use_yn" name="s_use_yn" class="form-control">
												<option value="">- 전체 -</option>
												<option value="Y" selected="selected">사용</option>
												<option value="N">미사용</option>
											</select>
										</td>
										<td>
											<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<!-- /검색영역 -->
						<div class="col-5">
							<!-- 조회결과 -->
							<div class="title-wrap mt10">
								<h4>조회결과</h4>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
							</div>
							<div id="auiGridLeft" style="margin-top: 5px; height: 385px; "></div>
							<!-- /조회결과 -->
						</div>
						<div class="col-7">
							<!-- 옵션목록 -->
							<div class="title-wrap mt10">
								<h4>옵션목록</h4>
								<div class="btn-group">
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div id="auiGridRight" style="margin-top: 5px; height: 385px;"></div>
							<!-- /옵션목록 -->
						</div>
					</div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt" >0</strong>건
						</div>
					</div>
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->
</div>
	<!-- 사용자 정의 렌더러 - html textarea 태그 -->
	<div id="textAreaWrap">
		<textarea id="myTextArea" class="aui-grid-custom-renderer-ext" style="width:100%; height:90px;"></textarea>
	</div>
</form>
</body>
</html>