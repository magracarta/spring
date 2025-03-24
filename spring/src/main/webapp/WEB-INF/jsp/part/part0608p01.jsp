<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 고객 별 부품구매내역 > 고객추가
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-03-07 17:06:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGridTop1;
		var auiGridTop2;
		var auiGridTop3;
		var auiGridBom;

		$(document).ready(function() {
			createAUIGridTop1(); // 담당센터
			createAUIGridTop2(); // 메이커
			createAUIGridTop3(); // 모델
			createAUIGridBom(); // 고객 조회결과
			$M.setValue("s_masking_yn", "${inputParam.s_masking_yn}");
		});

		// 고객조회
		function goSearch() {
			var gridData = AUIGrid.getGridData(auiGridTop1);
			if(gridData.length == 0){
				alert("담당센터는 필수입력입니다.");
				return false;
			}
			var frm = fnProcessForm();
			if (frm == false) {
				return false;
			}
			$M.goNextPageAjax(this_page+"/search", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGridBom, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			);
		}

		// 검색조건 세팅
		function fnProcessForm() {
			var frm = $M.toValueForm(document.main_form);
			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGridTop1, auiGridTop2, auiGridTop3];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			var gridForm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridForm, frm);
			return gridForm;
		}
		// 센터 추가
		function goAddCenter() {
			var param = {
				multi_yn : "Y"
			}
			openOrgMapCenterPanel("fnSetCenter", $M.toGetParam(param));
		}

		function fnSetCenter(row) {
			if(AUIGrid.getItemsByValue(auiGridTop1, "center_org_code", row.org_code).length != 0) {
				return "이미 추가된 센터입니다.";
			}
			AUIGrid.addRow(auiGridTop1, {"center_org_code":row.org_code,"center_org_name":row.org_name}, 'last');
		}

		// 센터 삭제
		function fnRemoveCenter() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridTop1);
			if (checkedItems.length == 0) {
				alert("선택된 센터가 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridTop1, checkedItems[i]._$uid);
				}
			}
		}

		// 메이커 추가
		function goAddMaker() {
			var modelData = AUIGrid.getGridData(auiGridTop3);
			if(modelData.length == 0){
				var params = {
					"parent_js_name" : "fnSetMaker",
					"multi_yn" : "Y"
				};
				var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=500, left=0, top=0";
				$M.goNextPage('/sale/sale0504p02', $M.toGetParam(params), {popupStatus : popupOption});
			} else {
				alert("메이커와 모델 중 한가지의 조건만 사용하실 수 있습니다.")
			}
		}

		function fnSetMaker(row) {
			if(AUIGrid.getItemsByValue(auiGridTop2, "maker_cd", row.maker_cd).length != 0) {
				return "이미 추가된 메이커입니다.";
			}
			AUIGrid.addRow(auiGridTop2, {"maker_cd":row.maker_cd,"maker_name":row.maker_name}, 'last');
		}

		// 메이커 삭제
		function fnRemoveMaker() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridTop2);
			if (checkedItems.length == 0) {
				alert("선택된 메이커가 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridTop2, checkedItems[i]._$uid);
				}
			}
		}

		// 모델추가
		function goAddModel() {
			var makerData = AUIGrid.getGridData(auiGridTop2);
			if (makerData.length == 0) {
				openSearchModelPanel("fnSetModel", "Y");
			} else {
				alert("메이커와 모델 중 한가지의 조건만 사용하실 수 있습니다.");
			}
		}

		function fnSetModel(obj) {
			if (Array.isArray(obj) == true) {
				for (var i = 0; i < obj.length; ++i) {
					// 중복체크
					var isUnique = AUIGrid.isUniqueValue(auiGridTop3, "machine_plant_seq", obj[i].machine_plant_seq);
					if (isUnique == false) {
						continue;
					}
					var item = new Object();
					item.machine_name = obj[i].machine_name;
					item.machine_plant_seq = obj[i].machine_plant_seq;
					AUIGrid.addRow(auiGridTop3, item, 'last');
				}
			} else {
				var item = new Object();
				item.machine_name = obj.machine_name;
				item.machine_plant_seq = obj[i].machine_plant_seq;
				AUIGrid.addRow(auiGridTop3, item, 'last');
			}
			// if(AUIGrid.getItemsByValue(auiGridTop3, "machine_plant_seq", row.machine_plant_seq).length == 0) {
			// 	AUIGrid.addRow(auiGridTop3, {"machine_plant_seq":row.machine_plant_seq,"machine_name":row.machine_name}, 'last');
			// }
		}

		// 모델 삭제
		function fnRemoveModel() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridTop3);
			if (checkedItems.length == 0) {
				alert("선택된 모델이 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridTop3, checkedItems[i]._$uid);
				}
			}
		}

		// 담당센터 그리드
		function createAUIGridTop1() {
			var gridPros = {
				showRowNumColumn : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};

			var columnLayout = [
				{
					headerText : "센터명",
					dataField : "center_org_name",
				},
				{
					dataField : "center_org_code",
					visible : false
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop1 = AUIGrid.create("#auiGridTop1", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTop1, []);
		}

		// 메이커 그리드
		function createAUIGridTop2() {
			var gridPros = {
				showRowNumColumn : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};

			var columnLayout = [
				{
					dataField : "maker_cd",
					visible : false
				},
				{
					headerText : "메이커",
					dataField : "maker_name",

				},
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop2 = AUIGrid.create("#auiGridTop2", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTop2, []);
		}

		// 모델 그리드
		function createAUIGridTop3() {
			var gridPros = {
				showRowNumColumn : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};

			var columnLayout = [
				{
					headerText : "모델명",
					dataField : "machine_name",
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop3 = AUIGrid.create("#auiGridTop3", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTop3, []);
		}

		// 대상고객 그리드
		function createAUIGridBom() {
			var gridPros = {
				showRowNumColumn : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};

			var columnLayout = [
				{
					headerText : "고객명",
					dataField : "cust_name",
				},
				{
					headerText : "담당센터",
					dataField : "center_org_name",
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
				},
				{
					dataField : "maker_cd",
					visible : false
				},
				{
					headerText : "모델",
					dataField : "machine_name",
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					dataField : "masking_cust_name",
					visible : false
				},
				{
					dataField : "masking_hp_no",
					visible : false
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "hp_no",
					visible : false
				},
				{
					dataField : "cust_machine_seq",
					visible : false
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridBom, []);
		}

		// 체크 후 적용
		function goApplyChecked() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridBom);
			if (checkedItems.length == 0) {
				alert("선택된 고객이 없습니다.");
				return false;
			}
			// 로딩바 작동하지 않아 강제 노출 후 타임아웃추가함.
			top.$('#popup-bg-loading').show();
			top.$('#bowlG').show();
			
			setTimeout(function (){
				opener.${inputParam.parent_js_name}(checkedItems);
				window.close();
			}, 1000);
		}

		// 전체적용
		function goApply() {
			var items = AUIGrid.getGridData(auiGridBom);	// 그리드 데이터
			if (items.length == 0) {
				alert("적용할 고객 정보가 없습니다.");
				return false;
			}
			// 로딩바 작동하지 않아 강제 노출 후 타임아웃추가함.
			top.$('#popup-bg-loading').show();
			top.$('#bowlG').show();

			setTimeout(function (){
				opener.${inputParam.parent_js_name}(items);
				window.close();
			}, 1000);

		}

		// 고객 개별추가
		function fnAddCust() {
			var param = {
				"multi_yn" : "Y"
			};
			openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param))
		}

		// 개별추가한 고객 최근 구매 장비 세팅
		function fnSetCustInfo(data) {
			if(AUIGrid.getItemsByValue(auiGridBom, "cust_no", data.cust_no).length != 0) {
				return false;
			}

				var param = {
				"s_cust_no" : data.cust_no,
				"s_masking_yn" : $M.getValue("s_masking_yn"),
			};

			$M.goNextPageAjax(this_page + "/data/search", $M.toGetParam(param), {method : 'GET'},
					function(result) {
						if(result.success) {
							var item = new Object();
							item.cust_no = result.custInfo.cust_no == null ? "" : result.custInfo.cust_no
							item.cust_name = result.custInfo.cust_name == null ? "" : result.custInfo.cust_name;
							item.masking_cust_name = result.custInfo.masking_cust_name == null ? "" : result.custInfo.masking_cust_name;
							item.masking_hp_no = result.custInfo.masking_hp_no == null ? "" : result.custInfo.masking_hp_no;
							item.hp_no = result.custInfo.hp_no == null ? "" : result.custInfo.hp_no;
							item.center_org_name = result.custInfo.center_org_name == null ? "" : result.custInfo.center_org_name;
							item.maker_name = result.custInfo.maker_name == null ? "" : result.custInfo.maker_name;
							item.maker_cd = result.custInfo.maker_cd == null ? "" : result.custInfo.maker_cd;
							item.machine_name = result.custInfo.machine_name == null ? "" : result.custInfo.machine_name;
							item.machine_plant_seq = result.custInfo.machine_plant_seq == null ? "" : result.custInfo.machine_plant_seq;
							// item.cust_machine_seq = result.custInfo.cust_machine_seq;
							AUIGrid.addRow(auiGridBom, item, 'last');
						}
					}
			);
		}

		// 고객삭제
		function fnRemoveCust() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridBom);
			if (checkedItems.length == 0) {
				alert("선택된 고객이 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridBom, checkedItems[i]._$uid);
				}
			}
		}
		// 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" name="s_masking_yn" id="s_masking_yn">
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<!-- contents 전체 영역 -->
	<div class="content-wrap">
			<div class="content-box">
				<div class="contents">
					<div class="row mt10">
						<div class="col-4 box-gray">
<!-- 담당센터 -->
							<div class="title-wrap mt5">
								<div class="form-check form-check-inline">
									<h4>담당센터(필수)</h4>
								</div>
								<div class="right">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goAddCenter()">추가</button>
									<button type="button" class="btn btn-primary-gra" onclick="javascript:fnRemoveCenter()">삭제</button>
								</div>
							</div>
							<div id="auiGridTop1" style="margin-top: 5px; height: 250px;"></div>
<!-- /담당센터 -->
						</div>
						<div class="col-4 box-gray">
<!-- 메이커 -->
							<div class="title-wrap mt5">
								<div class="form-check form-check-inline">
									<h4>메이커</h4>
								</div>
								<div class="right">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goAddMaker()">추가</button>
									<button type="button" class="btn btn-primary-gra" onclick="javascript:fnRemoveMaker()">삭제</button>
								</div>
							</div>
							<div id="auiGridTop2" style="margin-top: 5px; height: 250px;"></div>
<!-- /메이커 -->
						</div>
						<div class="col-4 box-gray">
<!-- 모델 -->
							<div class="title-wrap mt5">
								<div class="form-check form-check-inline">
									<h4>모델</h4>
								</div>
								<div class="right">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goAddModel()">추가</button>
									<button type="button" class="btn btn-primary-gra" onclick="javascript:fnRemoveModel()">삭제</button>
								</div>
							</div>
							<div id="auiGridTop3" style="margin-top: 5px; height: 250px;"></div>
						</div>
					</div>
					<div class="btn-group mt5">
						<div class="right">
							<button type="button" class="btn btn-info" onclick="javascript:goSearch()">고객조회</button>
						</div>
					</div>
					<div class="row">
						<div class="col-12">
<!-- 대상고객 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="right">
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnAddCust()"><i class="material-iconsadd text-primary"></i> 개별추가</button>
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnRemoveCust()">삭제</button>
						</div>
					</div>
					<div id="auiGridBom" style="margin-top: 5px; height: 300px;"></div>
<!-- /대상고객 -->
				<div class="btn-group mt10">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
					<div class="right">
						<button type="button" class="btn btn-info" onclick="javascript:goApplyChecked()">체크 후 적용</button>
						<button type="button" class="btn btn-info" onclick="javascript:goApply()">전체적용</button>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
		</div>
				</div>
			</div>
		</div>
</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>