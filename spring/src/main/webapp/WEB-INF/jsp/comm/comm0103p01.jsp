<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 그룹코드 관리 > 팝업
-- 작성자 : 류성진
-- 최초 작성일 : 2022-08-24 18:03:57
-- 2022-12-14 jsk 코드발번 서버로 이동 (코드발번 룰 변경)
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var numberFormat = "thousand";
		var group_code = "";
		var all_yn = "";
		var show_extra_cols = "";
		var sort_key = "";
		var sort_method = "";
		// var codes = {};
		var regExp =  /^[A-Za-z0-9_+]*$/;// 코드 값 필터링 정규식
		// var codeRegExp = /([a-zA-Z]*)([0-9]+)/;
		// var codeOption = {};

		$(document).ready(function () {
			fnInit();
			// createAUIGrid(); // 로딩후 컬럼 계산
			goSearch();
		});

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "전년대비누적손익");
		}


		// 그리드 필수값 확인
		function fnCheckGridEmpty() {
			var default_cols = ["group_code", "code_name", "use_yn", "sort_no"];
			var required = '${inputParam.requireds}'
			if (required != ''){
				default_cols = default_cols.concat($.map('${inputParam.requireds}'.split(','), function(v) {
					return 'code_' + v;
				}))
			}

			return AUIGrid.validateGridData(auiGrid, default_cols, "필수 항목은 반드시 값을 입력해야합니다.");
		}


		function fnInit(){
			group_code = '${inputParam.group_code}';
			all_yn = '${inputParam.all_yn}';
			show_extra_cols = '${inputParam.show_extra_cols}'.split(',')
			if ( all_yn != 'Y' && all_yn != 'N' ) { // yn값 검사
				all_yn = '';
			}
			sort_key = '${inputParam.s_sort_key}';
			sort_method = '${inputParam.s_sort_method}';
		}

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		// 경력사항 행 추가
		function fnAdd() {
			// 그리드 필수값 체크
			if(fnCheckGridEmpty(auiGrid)){
				var item = new Object();

				item.group_code = group_code;
				// item.code = getNewCode(codeOption);
				item.code = "";
				item.code_name = "";
				item.show_yn = "Y";
				item.use_yn = 'Y';
				item.sort_no = 99;
				item.cmd = "C"

				// codes[item.code] = item;
				// if ( item.code == -1) {
				// 	alert("코드가 최대값에 도달하여 더 이상 발번이 불가능 합니다.\n관리자에게 문의하여 주세요.");
				// 	return;
				// }
				// console.log(item.code);

				AUIGrid.addRow(auiGrid, item, "last");
			}
		}

		// 조회
		function goSearch() {
			var param  = {
				s_group_code : group_code,
				s_sort_key : sort_key,
				s_sort_method : sort_method,
			};

			$M.goNextPageAjax("/comm/comm0103p01/search", $M.toGetParam(param), {method: "get"},
					function (result) {
						if (result.success) {
							var list = [];
							// codes = {};// 코드셋 초기화
							$("#title").html(result.list[0].code_name + "코드 - 조회결과");
							for (var i = 1; i < result.list.length; i++){
								var idx = result.list[i];
								// codes[idx.code] = idx;
								// codes[idx.code].cmd = 'U';
								if( all_yn != 'Y' && idx.use_yn == 'N')
									continue;
								list.push(result.list[i]);
							}
							// .exec()

							// var code = list[0].code;
							// var codeOptions = codeRegExp.exec(code);
							// codeOption.char = codeOptions[1]; // 문자
							// codeOption.code = parseInt(codeOptions[2]); // 숫자
							// codeOption.length = code.length; // 코드길이
							//
							// console.log(codeOption)
							createAUIGrid(result.list[0]);
							AUIGrid.setGridData(auiGrid, list);
						}
					}
			);
		}


		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			if( !fnCheckGridEmpty(auiGrid) ){
				return;
			}

			var columns = ["group_code", "code", "code_name", "show_yn", "use_yn", "sort_no"];

			for ( var i = 0; i < show_extra_cols.length; i++) {
				if (!/v[0-9]+/.test(show_extra_cols[i]) && show_extra_cols[i] != 'desc') {
					continue;
				}
				columns.push("code_" + show_extra_cols[i]);
			}

			var gridFrm = fnChangeGridDataToForm(auiGrid, true, columns);

			$M.goNextPageAjaxSave("/comm/comm0103/" + group_code, gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							goSearch();
						}
					}
			);
		}

		// 코드 발번 - 류성진
		// function getNewCode(option){
		// 	// const { length, char, code } = options;
		// 	var i = 1; // 증감수
		// 	var spaceLength = option.length - option.char.length; // 숫자영역 길이
		// 	var max = Array(spaceLength + 1).join('9'); // 숫자 최대값
		// 	var fullData = Array(spaceLength + 1).join('0'); // 숫자 자리수 채우기
		// 	console.log('코드 발번 - ',spaceLength, max, fullData);
		// 	while (true){ // 발번 루프
		// 		var idx = (option.code  + i); // 다음코드
		// 		var code = option.char + (fullData + idx).slice(-1 * spaceLength); // 앞자리 문자 + (0자리수채우기+ 코드int )
		//
		// 		if ( !codes[code] ) return code;
		// 		if ( max == idx) { break; } // 최대값 초과
		// 		// console.log(code, '실패');
		// 		i++; // 다음코드 탐색
		// 	}
		//
		// 	return -1; // 발번실패 - 모든 코드가 사용되고 있음
		// }

		// 창 닫기
		function fnClose() {
			window.close();
		}

		// 그리드 재생성
		function fnAUIGridInit() {
			destroyGrid();
			createAUIGrid();
		}

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
		}

		// 천 단위
		function fnSetNumberFormatToggle() {
			if (numberFormat == "all") {
				numberFormat = "thousand";
			} else {
				numberFormat = "all"
			}

			AUIGrid.resize(auiGrid);
		}

		function createAUIGrid(title) {
			var gridPros = {
				// Row번호 표시 여부
				rowIdField: "_$uid",
				showRowNumColum: true,
				showStateColumn: true,
				editable: true,
				enableFilter :true,
			};
			var layoutHide = [ "group_code"]
			var columnLayout = [
				{
					headerText: "그룹코드",
					dataField: "group_code",
					width: "160",
					minWidth: "150",
					style: "aui-center",
					visible : false,
					editable: true
				},
				{
					headerText: "코드",
					dataField: "code",
					width: "100",
					minWidth: "100",
					style: "aui-center",
					editable: false,
					visible : false,
				},
				{
					headerText:  title.code_name || "코드명",
					dataField: "code_name",
					width: "160",
					minWidth: "150",
					style: "aui-editable",
					editable: true,
					filter: {
						showIcon: true
					},
				},
			];

			/// 추가 컬럼
			for ( var i = 0; i < show_extra_cols.length; i++){
				if (!/v[0-9]+/.test(show_extra_cols[i]) && show_extra_cols[i] != 'desc'){
					continue;
				}
				var id = "code_" + show_extra_cols[i];

				columnLayout.push({
					headerText: title[id] ||"코드명",
					dataField:  id,
					width: "160",
					minWidth: "150",
					style: "aui-editable",
					editable: true
				})
			}

			columnLayout.push(
					{
						headerText: "사용여부",
						dataField: "use_yn",
						width: "100",
						minWidth: "100",
						style: "aui-center",
						editable: true,
						filter : {
							showIcon : true
						},
						renderer: {
							type : "CheckBoxEditRenderer",
							checked : true,
							checkValue : "Y",
							unCheckValue : "N",
							editable : true
						},
					},
					{
						headerText: "순서",
						dataField: "sort_no",
						width: "100",
						minWidth: "100",
						style: "aui-editable",
						editable: true,
						editRenderer : {
							type : "InputEditRenderer",
							onlyNumeric : true, // Input 에서 숫자만 가능케 설정,
							maxlength : 3,
							validator : function(oldValue, newValue, item, dataField, fromClipboard) {
								var isValid = false;
								var numVal = Number(newValue);
								if(!isNaN(numVal) && numVal >= 1) {
									isValid = true;
								}
								return { "validate" : isValid, "message"  : "0 보다 큰 수를 입력하세요." };
							}
							// 에디팅 유효성 검사
						},
					},
					// {
					// 	width : "50",
					// 	headerText : "삭제",
					// 	dataField : "removeBtn",
					// 	renderer : {
					// 		type : "ButtonRenderer",
					// 		onClick : function(event) {
					// 			var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
					// 			if (isRemoved) { // 삭제로우?
					// 				AUIGrid.restoreSoftRows(auiGrid, event.rowIndex);
					// 			} else {
					// 				AUIGrid.removeRow(event.pid, event.rowIndex, event);
					// 			};
					// 		},
					// 	},
					// 	labelFunction : function(rowIndex, columnIndex, value,headerText, item) {
					// 		return '삭제'
					// 	},
					// 	style : "aui-center",
					// 	editable : false,
					// }
				)

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.hideColumnByDataField(auiGrid, layoutHide);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
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
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">
					<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4 id="title">코드 - 조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
			<!-- 하단 버튼 -->
		</div>
		<!-- /contents 전체 영역 -->
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>