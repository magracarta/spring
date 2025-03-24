<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통팝업 > 업무DB > 업무DB팝업 > 파일업로드
-- 작성자 : 류성진
-- 최초 작성일 : 2023-03-06
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

		// 멀티 그리드
		var auiGrids = [];
		var target = {}; // 경로
		var bucketMachine = [];
		var file_upload_option = { // 파일 업로드 옵션
			upload_type : "WORKDB",
			file_type : "both",
			max_size : "512000",
		};

		var datas = [ // 그리드 컬럼 데이터 (초기화 데이터)
				[ // 권한 리스트
					// 부서권한
					<c:forEach items="${menuOrgList}" var="item">
					{
						path_org_name : '${item.path_org_name}'
						, org_cd : '${item.org_code}'
					},
					</c:forEach>
					// 업무권한
					<c:forEach items="${codeMap['JOB_AUTH']}" var="item">
					{
						path_org_name : '${item.code_name}'
						, org_cd : '${item.code_value}'
					},
					</c:forEach>
				],
				[ // 테그 리스트
					<c:forEach items="${codeMap['DB_TAG']}" var="item">
					{
						tag_name : '${item.code_name}'
						, org_cd : '${item.code_value}'
					},
					</c:forEach>
				],
				[ // 메이커 리스트
					<c:forEach items="${codeMap['MAKER']}" var="item">
					<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
					{
						maker_name : '${item.code_name}'
						, org_cd : '${item.code_value}'
					},
					</c:if>
					</c:forEach>
				]
		];

        $(document).ready(function () {
			createAUIGrid();
        });

		// 태그관리 - 그룹 코드 관리
		function goSetting() {
			var group_code_params = {
				group_code : "DB_TAG",
				all_yn : "Y",
			};
			openGroupCodeDetailPanel($M.toGetParam(group_code_params));
		}

		// 파일추가 callback function
		function setFileInfo(result) {
			var str = '';
			str += '<div class="table-attfile-item bbs_file" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			str += '<input type="hidden" id="file_seq" name="file_seq" value="' + result.file_seq + '"/>';
			str += '</div>';
			var title = $("#title");

			// 파일명이 없는경우 제목변경
			if (title.val() == '')
				title.val(result.file_name);
			$('#bbs_file_div').html(str);
		}

		// 업무디비 뎁스 조회 결과
		function fnSelectWorkDir(item){
			target = item;
			$M.setValue("path_folder_name", target.path_folder_name);
			$M.setValue("work_db_seq", target.work_db_seq);
		}

		// 모델추가
		function fnCallSearchMchPlant() {
			let param = {};
			// 체크된 메이커 중 가장 가장 상단의 메이커 코드 구하기
			let checkedItems = AUIGrid.getCheckedRowItemsAll(auiGrids[2]);
			if (checkedItems.length > 0) {
				param = {
					s_maker_cd : checkedItems[0].org_cd
				};
			}
			openSearchModelPanel('fnAddMchPlant', 'Y', $M.toGetParam(param));
		}

		// 모델추가 콜백 함수
		function fnAddMchPlant(data){
			for (let idx in data) {
				const machine = data[idx];
				if ( bucketMachine[machine.machine_plant_seq] ){
					alert("이미 추가된 장비입니다.");
					return;
				}

				bucketMachine[machine.machine_plant_seq] = true;
				AUIGrid.addRow(auiGrids[3], machine, "last");
			}
		}

		// 취소 (창닫기)
        function fnClose() {
            window.close();
        }

		// 그리드 생성
		function createAUIGrid() {
			var gridPros = [
				{ 	// 0번 그리드 (다운로드 권한)
					rowIdField : "_$uid",
					showRowCheckColumn : true,
					showRowNumColum: true,
					showStateColumn: false,
					editable: false,
					enableFilter :true,
				},
				{ 	// 1번 그리드 (적용태그)
					rowIdField : "_$uid",
					showRowCheckColumn : true,
					showRowNumColum: true,
					showStateColumn: false,
					editable: false,
					enableFilter :true,
				},
				{	// 2번 그리드 (메이커)
					rowIdField : "_$uid",
					showRowCheckColumn : true,
					showRowNumColum: true,
					showStateColumn: false,
					editable: false,
					enableFilter :true,
				},
				{	// 3번 그리드 (모델)
					rowIdField : "_$uid",
					showRowNumColum: true,
					editable: true,
				},
			];

			var columnLayouts = [
				[ /////////////////////////////////////////////////////// 0번 그리드 (다운로드 권한)
					{
						headerText: "권한명",
						dataField: "path_org_name",
						style: "aui-center",
						filter : {
							showIcon : true
						},
						editable: false
					},
					{
						headerText: "권한코드",
						dataField: "org_cd",
						style: "aui-center",
						visible : false,
						editable: false
					},
				],
				[ /////////////////////////////////////////////////////// 1번 그리드 (적용태그)
					{
						headerText: "태그명",
						dataField: "tag_name",
						style: "aui-center",
						filter : {
							showIcon : true
						},
						editable: false
					},
					{
						headerText: "태그코드",
						dataField: "org_cd",
						style: "aui-center",
						visible : false,
						editable: false
					},
				],
				[ /////////////////////////////////////////////////////// 2번 그리드 (메이커)
					{
						headerText: "메이커명",
						dataField: "maker_name",
						style : "aui-center",
						filter : {
							showIcon : true
						},
						editable: false
					},
					{
						headerText: "메이커코드",
						dataField: "org_cd",
						style: "aui-center",
						visible : false,
						editable: false
					},
				],
				[ /////////////////////////////////////////////////////// 3번 그리드 (모델)
					{
						headerText: "모델명",
						dataField: "machine_name",
						minWidth: "170",
						style : "aui-center",
						editable: false,
						filter : {
							showIcon : true
						},
					},
					{
						dataField: "machine_plant_seq",
						visible : false,
					},
					{
						headerText: "차대번호 시작",
						dataField: "st_body_no",
						width: "130",
						editable: true,
						style: "aui-editable",
					},
					{
						headerText: "차대번호 끝",
						dataField: "ed_body_no",
						width: "130",
						editable: true,
						style: "aui-editable",
					},
					{
						headerText: "삭제",
						dataField: "removeBtn",
						width: "60",
						style: "aui-center",
						editable: false,
						renderer: {
							type: "ButtonRenderer",
							onClick: function (event) {
								var isRemoved = AUIGrid.isRemovedById(auiGrids[3], event.item._$uid);
								if (isRemoved == false) {
									AUIGrid.removeRow(event.pid, event.rowIndex);
								} else {
									AUIGrid.restoreSoftRows(auiGrids[3], "selectedIndex");
								}
							}
						},
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
							return '삭제';
						},
					},
				]
			];

			// 그리드들
			for (var i = 0; i < columnLayouts.length; i++){
				var auiGrid = AUIGrid.create("#auiGrid" + i, columnLayouts[i], gridPros[i]);
				AUIGrid.setGridData(auiGrid, datas[i]); // 데이터 설정
				// AUIGrid.bind(auiGrid, "cellClick", clickItem); // 셀클릭 이벤트
				auiGrids[i] = auiGrid;

				$("#auiGrid" + i).resize();
			}
		}

		// 저장
		function goSave() {
			if ($M.validation(document.main_form) == false) {
				return;
			}

			// 첨부파일 확인
			if (!$M.getValue("file_seq")) {
				alert("첨부파일은 필수입력입니다.");
				return;
			}

			// 차대번호 FROM TO 모두 있는지 확인
			// const mchGridData = AUIGrid.getGridData(auiGrids[3]);
			// if (mchGridData.length > 0) {
			// 	if (mchGridData.every(obj => obj.st_body_no && obj.ed_body_no) === false) {
			// 		alert("차대번호의 범위를 설정해주세요.");
			// 		return;
			// 	}
			// }

			var frm = $M.toValueForm(document.main_form);
			let machinePlantSeqArr = [];
			let stBodyNoArr = [];
			let edBodyNoArr = [];
			let cmdArr = [];

			// 모델 그리드 추가내역
			AUIGrid.getAddedRowItems(auiGrids[3]).forEach(data => {
				machinePlantSeqArr.push(data.machine_plant_seq);
				stBodyNoArr.push(data.st_body_no);
				edBodyNoArr.push(data.ed_body_no);
				cmdArr.push("C");
			});

			const option = {
				isEmpty : true
			};

			$M.setHiddenValue(frm, "machine_plant_seq_str", $M.getArrStr(machinePlantSeqArr, option));
			$M.setHiddenValue(frm, "st_body_no_str", $M.getArrStr(stBodyNoArr, option));
			$M.setHiddenValue(frm, "ed_body_no_str", $M.getArrStr(edBodyNoArr, option));
			$M.setHiddenValue(frm, "cmd_str", $M.getArrStr(cmdArr, option));

			// 그리드 선택항목 (옵션값)
			var gridNames = ["down_auths", "tags", "maker_cds"];
			for (var i in auiGrids) {
				var auiGrid = auiGrids[i];
				var gridName = gridNames[i];

				var rows = AUIGrid.getCheckedRowItems(auiGrid);
				var out = [];
				for (var j in rows) { // 값 추출
					out.push(rows[j].item.org_cd)
				}

				$M.setHiddenValue(frm, gridName, out.join("#"));
			}

			$M.goNextPageAjaxSave("/workDb2/mkfile", frm, {method: "POST"},
					function (result) {
						if (result.success) {
							window.opener.goMain($M.getValue('work_db_seq')); // 매인이동 함수
							// window.opener.goMain(); // 매인이동 함수
							window.close();
						}
					}
			);
		}
    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="work_db_seq" id="work_db_seq" value="${inputParam.work_db_seq}">
	<input type="hidden" name="end_dt" id="end_dt" value="${item.end_dt}"> <!-- 만료일 (yyyymmdd) -->
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- 컨텐츠 영역 -->
		<div class="content-wrap">
			<!-- 검색 영역 -->
			<div class="search-wrap mt10">
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">분류</th>
							<td>
								<input type="text" class="essential-bg"
									   id="path_folder_name" name="path_folder_name"
									   value="${depth.path_folder_name}"
									   style="width : 80%"
									   required="required"
									   readonly="readonly"
									   alt="분류"
									   placeholder="분류를 선택 해 주세요."
								>
								<!-- UP_WORK_DB_SEQ -->
								<button type="button" class="btn btn-default" onclick="openWorkDbGroup('fnSelectWorkDir')">분류수정</button>
							</td>
							<th class="text-right">작성자</th>
							<td>
								<input type="text" class="form-control" readonly="" value="${SecureUser.user_name}">
							</td>
							<th class="text-right">작성일</th>
							<td>
								<div class="form-row inline-pd widthfix">
								<div class="col width120px">
									<input type="text" class="form-control" id="start_dt" name="start_dt" dateFormat="yyyy-MM-dd" readonly="readonly" value="${item.start_dt}">
								</div>
								<div class="col width120px" style="margin-left: 10px;">
									만료일 : ${item.end_date}
								</div>
							</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">제목</th>
							<td>
								<input type="text" class="form-control essential-bg" id="title" name="title" required="required" value="" alt="제목" placeholder="제목" maxlength="100">
							</td>
							<th class="text-right essential-item">첨부파일</th>
							<td>
								<div class="bbs_file_div" style="width:100%;">
									<div class="table-attfile" style="float:left">
										<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="openFileUploadPanel('setFileInfo', $M.toGetParam(file_upload_option))">파일찾기</button>
									</div>
								</div>
								<div id="bbs_file_div">
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<!-- 그리드 영역 -->
			<div class="row mt10">
				<div class="col-3">
					<div class="title-wrap">
						<h4>다운로드권한</h4>
					</div>
					<div id="auiGrid0" style="margin-top: 5px; height: 300px;"></div>
				</div>
				<div class="col-2">
					<div class="title-wrap">
						<h4>적용태그</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGrid1" style="margin-top: 5px; height: 300px;"></div>
				</div>
				<div class="col-2">
					<div class="title-wrap">
						<h4>메이커</h4>
					</div>
					<div id="auiGrid2" style="margin-top: 5px; height: 300px;"></div>
				</div>
				<div class="col-5">
					<div class="title-wrap">
						<h4>모델</h4>
						<div class="btn-group">
							<div class="right">
								<button type="button" class="btn btn-info" onclick="fnCallSearchMchPlant()">모델추가</button>
							</div>
						</div>
					</div>
					<div id="auiGrid3" style="margin-top: 5px; height: 300px;"></div>
				</div>
			</div>
			<!-- 하위 버튼 영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
</form>
</body>
</html>
